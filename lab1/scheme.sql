CREATE TABLE IF NOT EXISTS council (
    id SERIAL PRIMARY KEY,
    name VARCHAR(80) UNIQUE NOT NULL,
    description VARCHAR(1000)
);

CREATE TABLE IF NOT EXISTS humans (
    id SERIAL PRIMARY KEY,
    id_council SERIAL,
    name VARCHAR(80) UNIQUE NOT NULL,
    mood VARCHAR(30) NOT NULL,
    age INTEGER NOT NULL,
    phone VARCHAR(20) NOT NULL,
    FOREIGN KEY(id_council) REFERENCES council(id)
);

CREATE TABLE IF NOT EXISTS states_names (
    state SERIAL PRIMARY KEY,
    name VARCHAR(80) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS drawings_future (
    id SERIAL PRIMARY KEY,
    date DATE,
    state INTEGER,
    FOREIGN KEY(state) REFERENCES states_names(state)
);

CREATE TABLE IF NOT EXISTS positions (
    id SERIAL PRIMARY KEY,
    id_humans SERIAL,
    id_drawings_future SERIAL,
    coordinates VARCHAR(30) NOT NULL,
    FOREIGN KEY(id_humans) REFERENCES humans(id),
    FOREIGN KEY(id_drawings_future) REFERENCES drawings_future(id)
);

CREATE TABLE IF NOT EXISTS reports_storms (
    grade SERIAL PRIMARY KEY,
    name VARCHAR(80) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS storms (
    id SERIAL PRIMARY KEY,
    time_start TIMESTAMP NOT NULL,
    time_end TIMESTAMP NOT NULL,
    grade INTEGER,
    FOREIGN KEY(grade) REFERENCES reports_storms(grade)
);

CREATE TABLE IF NOT EXISTS reports (
    id SERIAL PRIMARY KEY,
    id_humans SERIAL,
    id_storms SERIAL,
    date DATE NOT NULL,
    description VARCHAR(1000),
    FOREIGN KEY(id_humans) REFERENCES humans(id),
    FOREIGN KEY(id_storms) REFERENCES storms(id)
);
