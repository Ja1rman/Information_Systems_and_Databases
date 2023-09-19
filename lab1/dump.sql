INSERT INTO council (name, description) VALUES ('Совет Бэкендеров', 'Для фанатов бэкенда :/');
INSERT INTO council (name, description) VALUES ('Совет Шизиков', 'Для шизиков');

INSERT INTO humans (id_council, name, mood, age, phone) VALUES (2, 'John', '#В_шоке', 21, '+1 999 122 09 11');
INSERT INTO humans (id_council, name, mood, age, phone) VALUES (2, 'Васян', '#На_чиле', 20, '+1 999 132 09 11');
INSERT INTO humans (id_council, name, mood, age, phone) VALUES (2, 'Рофлян', '#На_расслабоне', 19, '+1 949 122 09 11');
INSERT INTO humans (id_council, name, mood, age, phone) VALUES (1, 'Алан', '#В_итмо', 21, '+1 995 122 09 11');

INSERT INTO states_names (name) VALUES ('Осторожное выжидание');
INSERT INTO states_names (name) VALUES ('НЕОсторожное выжидание');
INSERT INTO states_names (name) VALUES ('В АТАКУ');
INSERT INTO states_names (name) VALUES ('На колёсах');

INSERT INTO drawings_future (date, state) VALUES ('2023-09-19', 1);
INSERT INTO drawings_future (date, state) VALUES ('2023-09-20', 2);

INSERT INTO positions (id_humans, id_drawings_future, coordinates) VALUES (1, 2, '10:20:15');
INSERT INTO positions (id_humans, id_drawings_future, coordinates) VALUES (2, 2, '10:30:45');
INSERT INTO positions (id_humans, id_drawings_future, coordinates) VALUES (3, 2, '1:20:5');
INSERT INTO positions (id_humans, id_drawings_future, coordinates) VALUES (4, 2, '60:24:12');

INSERT INTO reports_storms (name) VALUES ('Нельзя разобраться');
INSERT INTO reports_storms (name) VALUES ('Плохая погода');
INSERT INTO reports_storms (name) VALUES ('mr Putin champion');
INSERT INTO reports_storms (name) VALUES ('Действия неверны');

INSERT INTO storms (time_start, time_end, grade) VALUES ('2023-09-20 05:20:54', '2023-09-24 05:20:54', 1);
INSERT INTO storms (time_start, time_end, grade) VALUES ('2023-09-20 01:20:54', '2023-09-20 05:20:54', 1);

INSERT INTO reports (id_humans, id_storms, date, description) VALUES (2, 1, '2023-09-20 11:17:45', 'невозможно разработать никакого определенного общего плана политических действий');
INSERT INTO reports (id_humans, id_storms, date, description) VALUES (1, 1, '2023-09-20 11:17:45', 'невозможно разработать никакого определенного общего плана политических действий');
INSERT INTO reports (id_humans, id_storms, date, description) VALUES (3, 1, '2023-09-20 11:17:45', 'невозможно разработать никакого определенного общего плана политических действий');
INSERT INTO reports (id_humans, id_storms, date, description) VALUES (4, 1, '2023-09-20 11:17:45', 'невозможно разработать никакого определенного общего плана политических действий');
