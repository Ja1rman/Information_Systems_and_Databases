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
    photo TEXT[] NOT NULL,
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
