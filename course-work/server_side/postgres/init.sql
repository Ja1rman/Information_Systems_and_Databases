CREATE TABLE IF NOT EXISTS Users (
    user_id SERIAL PRIMARY KEY,
    vk_id TEXT UNIQUE NULLS NOT DISTINCT,
    yandex_id TEXT UNIQUE NULLS NOT DISTINCT,
    avito_id TEXT UNIQUE NULLS NOT DISTINCT,
    gosuslugi_id TEXT UNIQUE NULLS NOT DISTINCT,
    name TEXT NOT NULL,
    surname TEXT NOT NULL,
    patronymic TEXT,
    email TEXT NOT NULL UNIQUE,
    phone_number TEXT NOT NULL UNIQUE,
    passport_path TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS Notification (
    notify_id SERIAL PRIMARY KEY,
    notify_text TEXT,
    notify_header TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS Notifications (
    notify_id INT NOT NULL REFERENCES Notification(notify_id) ON DELETE CASCADE,
    user_id INT NOT NULL REFERENCES Users(user_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Feedback (
    feedback_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES Users(user_id) ON DELETE CASCADE,
    writer_id INT NOT NULL REFERENCES Users(user_id) ON DELETE CASCADE,
    comment TEXT,
    rating INT NOT NULL CHECK (rating > 0 AND rating < 6),
    CONSTRAINT unique_feedback UNIQUE (user_id, writer_id)
);

CREATE TABLE IF NOT EXISTS Models (
    model_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS Types (
    type_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS Colors (
    color_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS Ad (
    ad_id SERIAL PRIMARY KEY,
    owner_id INT REFERENCES Users(user_id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    price DOUBLE PRECISION NOT NULL CHECK (price >= 0),
    description TEXT,
    location TEXT,
    photo TEXT NOT NULL,
    model_id INT REFERENCES Models(model_id) ON DELETE CASCADE,
    type_id INT REFERENCES Types(type_id) ON DELETE CASCADE,
    color_id INT REFERENCES Colors(color_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Promotion (
    ad_id INT NOT NULL REFERENCES Ad(ad_id) ON DELETE CASCADE,
    boost_lvl INT NOT NULL,
    date_start TIMESTAMP NOT NULL,
    date_end TIMESTAMP NOT NULL,
    CONSTRAINT check_start_end_dates CHECK (date_start < date_end)
);

CREATE TABLE IF NOT EXISTS Calendar (
    ad_id INT PRIMARY KEY REFERENCES Ad(ad_id) ON DELETE CASCADE,
    date_start TIMESTAMP NOT NULL,
    date_end TIMESTAMP NOT NULL,
    client_id INT NOT NULL REFERENCES Users(user_id) ON DELETE CASCADE
    CONSTRAINT check_start_end_dates CHECK (date_start < date_end)
);

CREATE TABLE IF NOT EXISTS Views (
    user_id INT NOT NULL REFERENCES Users(user_id) ON DELETE CASCADE,
    ad_id INT NOT NULL REFERENCES Ad(ad_id) ON DELETE CASCADE,
    CONSTRAINT unique_views UNIQUE (user_id, ad_id)
);

CREATE TABLE IF NOT EXISTS Favorites (
    user_id INT NOT NULL REFERENCES Users(user_id) ON DELETE CASCADE,
    ad_id INT NOT NULL REFERENCES Ad(ad_id) ON DELETE CASCADE,
    CONSTRAINT unique_favorites UNIQUE (user_id, ad_id)
);

CREATE TABLE IF NOT EXISTS Chat (
    chat_id SERIAL PRIMARY KEY,
    ad_id INT NOT NULL REFERENCES Ad(ad_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Chats (
    user_id INT NOT NULL REFERENCES Users(user_id) ON DELETE CASCADE,
    chat_id INT NOT NULL REFERENCES Chat(chat_id) ON DELETE CASCADE,
    CONSTRAINT unique_chat UNIQUE (user_id, chat_id)
);

CREATE TABLE IF NOT EXISTS Message (
    message_id SERIAL PRIMARY KEY,
    message TEXT,
    sending_date TIMESTAMP NOT NULL CHECK (sending_date <= CURRENT_TIMESTAMP),
    user_id INT NOT NULL REFERENCES Users(user_id) ON DELETE CASCADE,
    attachments TEXT[],
    chat_id INT NOT NULL REFERENCES Chat(chat_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Message_status (
    message_id INT NOT NULL REFERENCES Message(message_id) ON DELETE CASCADE,
    user_id INT NOT NULL REFERENCES Users(user_id) ON DELETE CASCADE,
    is_read BOOLEAN NOT NULL,
    CONSTRAINT unique_message_status UNIQUE (message_id, user_id)
);
CREATE OR REPLACE FUNCTION delete_expired_promotions() RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM Promotion
    WHERE date_end < CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Триггер для удаления устаревшей информации
CREATE OR REPLACE TRIGGER before_insert_promotion
BEFORE INSERT ON Promotion
FOR EACH ROW
EXECUTE FUNCTION delete_expired_promotions();

CREATE OR REPLACE FUNCTION check_user_chat_access() RETURNS TRIGGER AS $$
DECLARE
    chat_exists INT;
BEGIN
    -- Проверяем существование связи между пользователем и чатом
    SELECT COUNT(*) INTO chat_exists
    FROM Chats
    WHERE user_id = NEW.user_id AND chat_id = NEW.chat_id;

    IF chat_exists = 0 THEN
        RAISE EXCEPTION 'Пользователь не имеет доступ к данному чату';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Триггер для проверки доступа к чату
CREATE OR REPLACE TRIGGER before_insert_message
BEFORE INSERT ON Message
FOR EACH ROW
EXECUTE FUNCTION check_user_chat_access();

CREATE OR REPLACE FUNCTION prevent_read_message_status_change()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM Message_status 
        WHERE message_id = NEW.message_id 
            AND user_id = NEW.user_id 
            AND is_read = TRUE
    ) THEN
        RAISE EXCEPTION 'Обновление прочитанного сообщения запрещено.';
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER block_read_status_change
BEFORE UPDATE ON Message
FOR EACH ROW EXECUTE FUNCTION prevent_read_message_status_change();

CREATE OR REPLACE FUNCTION notify_new_message()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO Notification (notify_text, notify_header)
    VALUES ('У вас новое сообщение.', 'Новое сообщение');

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER new_message_trigger
AFTER INSERT ON Message
FOR EACH ROW
EXECUTE FUNCTION notify_new_message();

CREATE OR REPLACE FUNCTION prevent_user_deletion()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM Ad WHERE owner_id = OLD.user_id) THEN
        RAISE EXCEPTION 'Нельзя удалить профиль с действующими объявлениями';
    ELSE
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER prevent_user_deletion_trigger
BEFORE DELETE ON Users
FOR EACH ROW
EXECUTE FUNCTION prevent_user_deletion();

CREATE OR REPLACE FUNCTION check_photos_on_create()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.photo IS NULL OR LENGTH(NEW.photo) = 0 THEN
        RAISE EXCEPTION 'Необходимо добавить хоть 1 фото.';
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER photos_check_trigger
BEFORE INSERT ON Ad
FOR EACH ROW
EXECUTE FUNCTION check_photos_on_create();
CREATE OR REPLACE FUNCTION GetAdInfo(ad_id_to_find INT) RETURNS SETOF Ad AS $$
BEGIN
    RETURN QUERY
    SELECT ad_id, owner_id, title, price, description, location, photo, model_id, type_id, color_id
    FROM Ad
    WHERE ad_id = ad_id_to_find;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION GetAdsByUser(user_id_to_find INT) RETURNS SETOF Ad AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM Ad
    WHERE
        owner_id = user_id_to_find;
    RETURN;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION GetUserInfo(user_id_to_find INT) RETURNS TABLE Users AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM Users
    WHERE user_id = user_id_to_find;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION GetUserChats(user_id_to_find INT) RETURNS SETOF Chats AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM Chats
    WHERE user_id = user_id_to_find;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION GetChatMessages(chat_id_to_find INT) RETURNS SETOF Message AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM Message
    WHERE chat_id = chat_id_to_find;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION GetBookedeDates(ad_id_to_find INT) RETURNS TABLE (
    date_start TIMESTAMP,
    date_end TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT Calendar.date_start, Calendar.date_end
    FROM Calendar
    WHERE ad_id = ad_id_to_find
      AND Calendar.date_end > CURRENT_TIMESTAMP;
END;
$$ LANGUAGE plpgsql;




CREATE OR REPLACE FUNCTION generate_insert_random_to_users()
RETURNS VOID AS $$
DECLARE
    counter INTEGER := 1;
BEGIN
    WHILE counter <= 500000 LOOP
        INSERT INTO Users (
            vk_id, yandex_id, avito_id, gosuslugi_id,
            name, surname, patronymic, email, phone_number, passport_path
        ) VALUES (
            substr(md5(random()::text), 1, 10), -- генерация случайной строки
            substr(md5(random()::text), 1, 10),
            substr(md5(random()::text), 1, 10),
            substr(md5(random()::text), 1, 10),
            substring(md5(random()::text) from 0 for 10),
            substring(md5(random()::text) from 0 for 10),
            substring(md5(random()::text) from 0 for 10),
            substr(md5(random()::text), 1, 10) || '@example.com',
            substr(md5(random()::text), 1, 10),
            '/path/to/passport/' || substr(md5(random()::text), 1, 10) || '.pdf'
        );
        counter := counter + 1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION generate_random_ad_data()
RETURNS VOID AS $$
DECLARE
    counter INTEGER := 1;
BEGIN
    WHILE counter <= 100000 LOOP -- Генерация 100 000 записей, можно изменить на нужное количество
        INSERT INTO Ad(owner_id, title, price, description, location, photo, model_id, type_id, color_id)
        VALUES (
            FLOOR(RANDOM() * 500000) + 1, -- Генерация owner_id от 1 до 500000
            'Title ' || counter, -- Генерация заголовка в соответствии с номером записи
            CAST(RANDOM() * 1000 AS NUMERIC(10, 2)), -- Генерация случайной цены от 0 до 1000
            'Description ' || counter, -- Генерация описания в соответствии с номером записи
            'Location ' || counter, -- Генерация местоположения в соответствии с номером записи
            ARRAY['photo_url_1', 'photo_url_2'], -- Заглушка для массива фото
            FLOOR(RANDOM() * 3) + 1, -- Генерация model_id от 1 до 3
            FLOOR(RANDOM() * 3) + 1, -- Генерация type_id от 1 до 3
            FLOOR(RANDOM() * 3) + 1  -- Генерация color_id от 1 до 3
        );
        counter := counter + 1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;
-- Заполнение таблицы Users
INSERT INTO Users (vk_id, yandex_id, avito_id, gosuslugi_id, name, surname, patronymic, email, phone_number, passport_path)
VALUES 
    ('VI123', 'YAN456', 'AVT789', 'GOS101', 'Иван', 'Иванов', 'Иванович', 'ivan@example.com', '+1234567890', '/passport/1.pdf'),
    ('VI234', 'YAN567', 'AVT890', 'GOS202', 'Петр', 'Петров', 'Петрович', 'petr@example.com', '+1987654321', '/passport/2.pdf'),
    ('VI345', 'YAN678', 'AVT901', 'GOS303', 'Мария', 'Сидорова', NULL, 'maria@example.com', '+1122334455', '/passport/3.pdf'),
    ('VI456', 'YAN789', 'AVT012', 'GOS404', 'Елена', 'Иванова', 'Петровна', 'elena@example.com', '+1555666777', '/passport/4.pdf'),
    ('VI567', 'YAN890', 'AVT123', 'GOS505', 'Алексей', 'Смирнов', 'Алексеевич', 'alex@example.com', '+1444333222', '/passport/5.pdf'),
    ('VI678', 'YAN901', 'AVT234', 'GOS606', 'Ольга', 'Кузнецова', 'Павловна', 'olga@example.com', '+1999888777', '/passport/6.pdf'),
    ('VI789', 'YAN012', 'AVT345', 'GOS707', 'Сергей', 'Козлов', 'Игоревич', 'sergey@example.com', '+1666999888', '/passport/7.pdf');

-- Заполнение таблицы Notification
INSERT INTO Notification (notify_text, notify_header)
VALUES 
    ('Уважаемые клиенты, акция на лизинг самосвалов до конца месяца!', 'Акция: Специальные условия лизинга'),
    ('Изменения в графике работы сервисного центра', 'Обновление: График работы'),
    ('Новые модели самосвалов уже в наличии!', 'Анонс: Новинки моделей'),
    ('Внимание! Изменения в правилах оформления договоров', 'Важно: Обновление правил'),
    ('Специальное предложение для постоянных клиентов', 'Акция: Для наших клиентов'),
    ('Важная информация по оплате лизинга', 'Важно: Оплата лизинга'),
    ('Приглашаем на день открытых дверей в нашем сервисе', 'Событие: День открытых дверей');

-- Заполнение таблицы Notifications (связь уведомлений с пользователями)
INSERT INTO Notifications (notify_id, user_id)
VALUES 
    (1, 1), (2, 2), (3, 3), (4, 4), (5, 5), (6, 6), (7, 7);

-- Заполнение таблицы Feedback
INSERT INTO Feedback (user_id, writer_id, comment, rating)
VALUES 
    (1, 3, 'Отличный сервис!', 5),
    (2, 1, 'Хороший выбор самосвалов', 4),
    (3, 5, 'Быстрая обработка документов', 4),
    (4, 2, 'Нужно улучшить условия лизинга', 3),
    (5, 4, 'Проблемы с доставкой', 2),
    (6, 7, 'Все отлично, спасибо!', 5),
    (7, 6, 'Приятное обслуживание', 4);

-- Заполнение таблицы Models, Types, Colors
INSERT INTO Models (name) VALUES ('Модель A'), ('Модель B'), ('Модель C');
INSERT INTO Types (name) VALUES ('Тип 1'), ('Тип 2'), ('Тип 3');
INSERT INTO Colors (name) VALUES ('Красный'), ('Синий'), ('Зеленый');

-- Заполнение таблицы Ad (объявления о самосвалах)
INSERT INTO Ad (owner_id, title, price, description, location, photo, model_id, type_id, color_id)
VALUES 
    (1, 'Самосвал Модель A', 1500000, 'Новый самосвал Модель A', 'Москва', ARRAY['photo1.jpg', 'photo2.jpg'], 1, 1, 1),
    (2, 'Самосвал Модель B', 1600000, 'Новый самосвал Модель B', 'Санкт-Петербург', ARRAY['photo3.jpg', 'photo4.jpg'], 2, 2, 2),
    (3, 'Самосвал Модель C', 1700000, 'Новый самосвал Модель C', 'Екатеринбург', ARRAY['photo5.jpg', 'photo6.jpg'], 3, 3, 3),
    (4, 'Самосвал Модель A', 1550000, 'Б/у самосвал Модель A', 'Новосибирск', ARRAY['photo7.jpg', 'photo8.jpg'], 1, 2, 2),
    (5, 'Самосвал Модель B', 1650000, 'Б/у самосвал Модель B', 'Красноярск', ARRAY['photo9.jpg', 'photo10.jpg'], 2, 3, 3),
    (6, 'Самосвал Модель C', 1750000, 'Б/у самосвал Модель C', 'Владивосток', ARRAY['photo11.jpg', 'photo12.jpg'], 3, 1, 1),
    (7, 'Самосвал Модель A', 1520000, 'Новый самосвал Модель A', 'Казань', ARRAY['photo13.jpg', 'photo14.jpg'], 1, 2, 3);

-- Заполнение таблицы Promotion (продвижение объявлений)
INSERT INTO Promotion (ad_id, boost_lvl, date_start, date_end)
VALUES 
    (1, 2, '2023-01-01', '2024-01-15'),
    (2, 1, '2023-02-01', '2024-02-10'),
    (3, 3, '2023-03-01', '2024-03-20'),
    (4, 1, '2023-04-01', '2024-04-05'),
    (5, 2, '2023-05-01', '2024-05-18'),
    (6, 3, '2023-06-01', '2024-06-25'),
    (7, 1, '2023-07-01', '2024-07-12');

-- Заполнение таблицы Calendar (запись расписания аренды самосвалов)
INSERT INTO Calendar (ad_id, date_start, date_end, client_id)
VALUES 
    (1, '2023-01-02', '2024-01-05', 3),
    (2, '2023-02-05', '2024-02-08', 4),
    (3, '2023-03-10', '2024-03-15', 5),
    (4, '2023-04-12', '2024-04-18', 6),
    (5, '2023-05-20', '2024-05-25', 7),
    (6, '2023-06-22', '2024-06-28', 1),
    (7, '2023-07-05', '2024-07-10', 2);

-- Заполнение таблицы Views (записи о просмотрах объявлений)
INSERT INTO Views (user_id, ad_id)
VALUES 
    (1, 4), (2, 6), (3, 2), (4, 7), (5, 3), (6, 5), (7, 1);

-- Заполнение таблицы Favorites (записи о избранных объявлениях)
INSERT INTO Favorites (user_id, ad_id)
VALUES 
    (1, 1), (2, 3), (3, 5), (4, 7), (5, 2), (6, 4), (7, 6);

-- Заполнение таблицы Chat (инициализация чатов по объявлениям)
INSERT INTO Chat (ad_id)
VALUES 
    (1), (2), (3), (4), (5), (6), (7);

-- Заполнение таблицы Chats (связь пользователей с чатами)
INSERT INTO Chats (user_id, chat_id)
VALUES 
    (1, 6), (2, 6), (3, 7), (4, 2), (5, 2), (6, 4), (7, 4);

-- Заполнение таблицы Message (сообщения в чатах)
INSERT INTO Message (message, sending_date, user_id, attachments, chat_id)
VALUES 
    ('Привет, я заинтересован в вашем самосвале', '2023-01-03', 3, ARRAY['photo15.jpg'], 7),
    ('Добрый день! Какие условия аренды?', '2023-02-06', 4, ARRAY['photo16.jpg'], 2),
    ('Здравствуйте, хочу уточнить информацию о доставке', '2023-03-12', 5, ARRAY['photo17.jpg'], 2),
    ('Здесь ли еще этот самосвал?', '2023-04-15', 6, ARRAY['photo18.jpg'], 4),
    ('Какая стоимость лизинга на этот самосвал?', '2023-05-22', 7, ARRAY['photo19.jpg'], 4),
    ('Здравствуйте, готовы ли вы к обсуждению цены?', '2023-06-24', 1, ARRAY['photo20.jpg'], 6),
    ('Прошу сообщить условия лизинга', '2023-07-07', 2, ARRAY['photo21.jpg'], 6);

-- Заполнение таблицы Message_status (статусы сообщений)
INSERT INTO Message_status (message_id, user_id, is_read)
VALUES 
    (1, 1, TRUE),
    (2, 2, TRUE),
    (3, 3, TRUE),
    (4, 4, FALSE),
    (5, 5, FALSE),
    (6, 6, FALSE),
    (7, 7, FALSE);
CREATE INDEX index_user_id ON Users USING HASH(user_id);
CREATE INDEX index_ad_id ON Ad USING HASH(ad_id);

