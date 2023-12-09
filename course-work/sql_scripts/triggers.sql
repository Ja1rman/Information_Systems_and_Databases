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
