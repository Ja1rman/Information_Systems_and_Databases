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
