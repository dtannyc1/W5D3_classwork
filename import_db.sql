PRAGMA foreign_keys = ON;

CREATE TABLE users (
        id INTEGER PRIMARY KEY,
        fname TEXT NOT NULL,
        lname TEXT NOT NULL
    );

CREATE TABLE questions (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        user_id INTEGER NOT NULL,

        FOREIGN KEY (user_id) REFERENCES users(id)
    );

CREATE TABLE question_follows (
        id INTEGER PRIMARY KEY,
        user_id INTEGER NOT NULL,
        question_id INTEGER NOT NULL,

        FOREIGN KEY (user_id) REFERENCES users(id),
        FOREIGN KEY (question_id) REFERENCES questions(id)
    );

CREATE TABLE replies (
        id INTEGER PRIMARY KEY,
        question_id INTEGER NOT NULL,
        reply_id INTEGER,
        user_id INTEGER NOT NULL,
        body TEXT NOT NULL,

        FOREIGN KEY (question_id) REFERENCES questions(id),
        FOREIGN KEY (reply_id) REFERENCES replies(id),
        FOREIGN KEY (user_id) REFERENCES users(id)
    );

CREATE TABLE question_likes (
        id INTEGER PRIMARY KEY,
        user_id INTEGER NOT NULL,
        question_id INTEGER NOT NULL,

        FOREIGN KEY (user_id) REFERENCES users(id),
        FOREIGN KEY (question_id) REFERENCES questions(id)
    );

INSERT INTO
    users (fname, lname)
VALUES
    ('Arthur', 'Miller'),
    ('Eugene', 'O''Neill'),
    ('David', 'Tan'),
    ('Tyvan', 'Cheng');

INSERT INTO
    questions (title, body, user_id)
VALUES
    ('Dog?', 'Who ate my dog?', 1),
    ('Cat?', 'Where is my cat?', 2);

INSERT INTO
    question_follows (user_id, question_id)
VALUES
    (3, 2),
    (4, 1);

INSERT INTO
    replies (question_id, reply_id, user_id, body)
VALUES
    (2, NULL, 3, 'I found your cat'),
    (2, 1, 2, 'Where?');

INSERT INTO
    question_likes (user_id, question_id)
VALUES
    (4, 1),
    (2, 2);
