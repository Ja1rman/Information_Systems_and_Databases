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
