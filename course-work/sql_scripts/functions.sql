CREATE OR REPLACE FUNCTION GetAdInfo(ad_id_to_find INT) RETURNS SETOF Ad AS $$
BEGIN
    RETURN QUERY
    SELECT *
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
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION GetUserInfo(user_id_to_find INT) RETURNS SETOF Users AS $$
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
