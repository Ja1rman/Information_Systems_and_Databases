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
    IF NEW.photo IS NULL OR array_length(NEW.photo, 1) = 0 THEN
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
