DROP FUNCTION IF EXISTS GetAdInfo(INT);
DROP FUNCTION IF EXISTS GetAdsByUser(INT);
DROP FUNCTION IF EXISTS GetUserInfo(INT);
DROP FUNCTION IF EXISTS GetUserChats(INT);
DROP FUNCTION IF EXISTS GetChatMessages(INT);
DROP FUNCTION IF EXISTS GetBookedeDates(INT);

DROP TRIGGER IF EXISTS before_insert_promotion ON Promotion;
DROP TRIGGER IF EXISTS before_insert_message ON Message;
DROP TRIGGER IF EXISTS block_read_status_change ON Message;
DROP TRIGGER IF EXISTS new_message_trigger ON Message;
DROP TRIGGER IF EXISTS prevent_user_deletion_trigger ON Users;
DROP TRIGGER IF EXISTS photos_check_trigger ON Ad;
DROP FUNCTION IF EXISTS delete_expired_promotions;
DROP FUNCTION IF EXISTS check_user_chat_access;
DROP FUNCTION IF EXISTS prevent_read_message_status_change;
DROP FUNCTION IF EXISTS notify_new_message;
DROP FUNCTION IF EXISTS prevent_user_deletion;
DROP FUNCTION IF EXISTS check_photos_on_create;

DROP TABLE IF EXISTS Message_status;
DROP TABLE IF EXISTS Message;
DROP TABLE IF EXISTS Chats;
DROP TABLE IF EXISTS Chat;
DROP TABLE IF EXISTS Favorites;
DROP TABLE IF EXISTS Views;
DROP TABLE IF EXISTS Calendar;
DROP TABLE IF EXISTS Promotion;
DROP TABLE IF EXISTS Ad;
DROP TABLE IF EXISTS Colors;
DROP TABLE IF EXISTS Types;
DROP TABLE IF EXISTS Models;
DROP TABLE IF EXISTS Feedback;
DROP TABLE IF EXISTS Notifications;
DROP TABLE IF EXISTS Notification;
DROP TABLE IF EXISTS Users;