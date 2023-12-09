CREATE INDEX index_user_id ON Users USING HASH(user_id);
CREATE INDEX index_ad_id ON Ad USING HASH(ad_id);
CREATE INDEX index_chat_id ON Chat USING HASH(chat_id);
