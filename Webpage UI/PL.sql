/* CS340 Group 46 Project - PL.sql */
   
/* Members: Son Thai Do Nguyen - Joshua Cicchinelli - Mauricio Marin Gutierrez */

/* PL - Procedures */

/* Reset */
DROP PROCEDURE IF EXISTS sp_reset_library;
DELIMITER //

CREATE PROCEDURE sp_reset_library()
BEGIN
    /* Make the reset predictable */
    SET FOREIGN_KEY_CHECKS = 0;

    /* Drop Tables */
    DROP TABLE IF EXISTS BookGenres;
    DROP TABLE IF EXISTS BookAuthors;
    DROP TABLE IF EXISTS Loans;
    DROP TABLE IF EXISTS BookCopies;
    DROP TABLE IF EXISTS Genres;
    DROP TABLE IF EXISTS Authors;
    DROP TABLE IF EXISTS Patrons;
    DROP TABLE IF EXISTS Books;

    /* Create Tables */
    CREATE TABLE Books (
      bookID INT AUTO_INCREMENT PRIMARY KEY,
      ISBN VARCHAR(13) NOT NULL,
      title VARCHAR(255) NOT NULL,
      publicationYear YEAR NULL,
      publisher VARCHAR(100) NULL,
      bookMedia ENUM('Hardcover','Paperback','E-Book','Audio') NOT NULL,
      CONSTRAINT uq_Books_ISBN UNIQUE (ISBN)
    ) ENGINE=InnoDB;

    CREATE TABLE Patrons (
      patronID INT AUTO_INCREMENT PRIMARY KEY,
      libraryCardNumber VARCHAR(20) NOT NULL,
      firstName VARCHAR(50) NOT NULL,
      lastName VARCHAR(50) NOT NULL,
      email VARCHAR(100) NOT NULL,
      phone VARCHAR(12) NULL,
      CONSTRAINT uq_Patrons_libraryCardNumber UNIQUE (libraryCardNumber),
      CONSTRAINT uq_Patrons_email UNIQUE (email)
    ) ENGINE=InnoDB;

    CREATE TABLE Authors (
      authorID INT AUTO_INCREMENT PRIMARY KEY,
      firstName VARCHAR(50) NOT NULL,
      lastName VARCHAR(50) NOT NULL,
      birthYear SMALLINT NULL
    ) ENGINE=InnoDB;

    CREATE TABLE Genres (
      genreID INT AUTO_INCREMENT PRIMARY KEY,
      genreName VARCHAR(50) NOT NULL,
      CONSTRAINT uq_Genres_genreName UNIQUE (genreName)
    ) ENGINE=InnoDB;

    CREATE TABLE BookCopies (
      copyID INT AUTO_INCREMENT PRIMARY KEY,
      bookID INT NOT NULL,
      acquisitionDate DATE NOT NULL,
      `condition` VARCHAR(20) NOT NULL,
      location VARCHAR(50) NOT NULL,
      status VARCHAR(20) NOT NULL,
      CONSTRAINT fk_BookCopies_Books
        FOREIGN KEY (bookID) REFERENCES Books(bookID)
        ON UPDATE CASCADE
        ON DELETE CASCADE
    ) ENGINE=InnoDB;

    CREATE TABLE BookAuthors (
      bookID INT NOT NULL,
      authorID INT NOT NULL,
      PRIMARY KEY (bookID, authorID),
      CONSTRAINT fk_BookAuthors_Books
        FOREIGN KEY (bookID) REFERENCES Books(bookID)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
      CONSTRAINT fk_BookAuthors_Authors
        FOREIGN KEY (authorID) REFERENCES Authors(authorID)
        ON UPDATE CASCADE
        ON DELETE CASCADE
    ) ENGINE=InnoDB;

    CREATE TABLE BookGenres (
      bookID INT NOT NULL,
      genreID INT NOT NULL,
      PRIMARY KEY (bookID, genreID),
      CONSTRAINT fk_BookGenres_Books
        FOREIGN KEY (bookID) REFERENCES Books(bookID)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
      CONSTRAINT fk_BookGenres_Genres
        FOREIGN KEY (genreID) REFERENCES Genres(genreID)
        ON UPDATE CASCADE
        ON DELETE CASCADE
    ) ENGINE=InnoDB;

    CREATE TABLE Loans (
      loanID INT AUTO_INCREMENT PRIMARY KEY,
      copyID INT NOT NULL,
      patronID INT NOT NULL,
      checkoutDate DATE NOT NULL DEFAULT CURRENT_DATE,
      dueDate DATE NOT NULL,
      returnDate DATE NULL,
      lateFee DECIMAL(5,2) NOT NULL DEFAULT 0.00,
      status ENUM('Active','Returned','Overdue','Lost') NOT NULL DEFAULT 'Active',
      CONSTRAINT fk_Loans_BookCopies
        FOREIGN KEY (copyID) REFERENCES BookCopies(copyID)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
      CONSTRAINT fk_Loans_Patrons
        FOREIGN KEY (patronID) REFERENCES Patrons(patronID)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
    ) ENGINE=InnoDB;
    SET FOREIGN_KEY_CHECKS = 1;

    /* Sample Data */
    -- Books
    INSERT INTO Books (ISBN, title, publicationYear, publisher, bookMedia) VALUES
    ('9780439708180', 'Harry Potter and the Sorcerer''s Stone', 1997, 'Scholastic', 'Hardcover'),
    ('9780439064873', 'Harry Potter and the Chamber of Secrets', 1998, 'Scholastic', 'Hardcover'),
    ('9780307743657', 'The Shining', 1977, 'Doubleday', 'Hardcover');

    -- Patrons
    INSERT INTO Patrons (libraryCardNumber, firstName, lastName, email, phone) VALUES
    ('LC1001', 'Mauricio', 'Gutierrez', 'mauricio.gutierrez@email.com', '5415552001'),
    ('LC1002', 'Joshua', 'Cicchinelli', 'joshua.cicchinelli@email.com', '5415552002'),
    ('LC1003', 'Son', 'Nguyen', 'son.nguyen@email.com', NULL);

    -- Authors
    INSERT INTO Authors (firstName, lastName, birthYear) VALUES
    ('J.K.', 'Rowling', 1965),
    ('Stephen', 'King', 1947),
    ('H.P.', 'Lovecraft', 1890);

    -- Genres
    INSERT INTO Genres (genreName) VALUES
    ('Fantasy'),
    ('Horror'),
    ('Fiction');

    -- BookCopies
    INSERT INTO BookCopies (bookID, acquisitionDate, `condition`, location, status) VALUES
    (1, '2023-03-01', 'Good', 'Shelf F1', 'Available'),
    (1, '2023-05-12', 'Worn', 'Shelf F1', 'Checked Out'),
    (2, '2022-10-10', 'Good', 'Shelf F2', 'Available'),
    (3, '2021-09-20', 'Good', 'Shelf H1', 'Available');

    -- BookAuthors
    INSERT INTO BookAuthors (bookID, authorID) VALUES
    (1, 1),
    (2, 1),
    (3, 2);

    -- BookGenres
    INSERT INTO BookGenres (bookID, genreID) VALUES
    (1, 1),
    (2, 1),
    (3, 2);

    -- Loans
    INSERT INTO Loans (copyID, patronID, checkoutDate, dueDate, returnDate, lateFee, status) VALUES
    (2, 1, '2026-02-01', '2026-02-15', NULL, 0.00, 'Active'),
    (1, 2, '2025-11-01', '2025-11-15', '2025-11-14', 0.00, 'Returned'),
    (4, 3, '2025-10-10', '2025-10-24', '2025-10-30', 1.50, 'Overdue');
END //

DELIMITER ;

/* Add Book */
DROP PROCEDURE IF EXISTS sp_insert_book;
DELIMITER //

CREATE PROCEDURE sp_insert_book(
    p_ISBN VARCHAR(13),
    p_title VARCHAR(255),
    p_publicationYear YEAR,
    p_publisher VARCHAR(100),
    p_bookMedia ENUM('Hardcover','Paperback','E-Book','Audio')
)
BEGIN
    INSERT INTO Books (ISBN, title, publicationYear, publisher, bookMedia)
    VALUES (p_ISBN, p_title, p_publicationYear, p_publisher, p_bookMedia);
END //

DELIMITER ;

/* Update Book */
DROP PROCEDURE IF EXISTS sp_update_book;
DELIMITER //

CREATE PROCEDURE sp_update_book(
    p_bookID INT,
    p_ISBN VARCHAR(13),
    p_title VARCHAR(255),
    p_publicationYear YEAR,
    p_publisher VARCHAR(100),
    p_bookMedia ENUM('Hardcover','Paperback','E-Book','Audio')
)
BEGIN
    UPDATE Books 
    SET ISBN = p_ISBN,
        title = p_title,
        publicationYear = p_publicationYear,
        publisher = p_publisher,
        bookMedia = p_bookMedia
    WHERE bookID = p_bookID;
END //

DELIMITER ;

/* Delete Book */
DROP PROCEDURE IF EXISTS sp_delete_book;
DELIMITER //

CREATE PROCEDURE sp_delete_book(p_bookID INT)
BEGIN
    DELETE FROM Books WHERE bookID = p_bookID;
END //

DELIMITER ;

/* Add Author */
DROP PROCEDURE IF EXISTS sp_insert_author;
DELIMITER //

CREATE PROCEDURE sp_insert_author(
    p_firstName VARCHAR(50),
    p_lastName VARCHAR(50),
    p_birthYear SMALLINT
)
BEGIN
    INSERT INTO Authors (firstName, lastName, birthYear)
    VALUES (p_firstName, p_lastName, p_birthYear);
END //

DELIMITER ;

/* Update Author */
DROP PROCEDURE IF EXISTS sp_update_author;
DELIMITER //

CREATE PROCEDURE sp_update_author(
    p_authorID INT,
    p_firstName VARCHAR(50),
    p_lastName VARCHAR(50),
    p_birthYear SMALLINT
)
BEGIN
    UPDATE Authors 
    SET firstName = p_firstName,
        lastName = p_lastName,
        birthYear = p_birthYear
    WHERE authorID = p_authorID;
END //

DELIMITER ;

/* Delete Author */
DROP PROCEDURE IF EXISTS sp_delete_author;
DELIMITER //

CREATE PROCEDURE sp_delete_author(p_authorID INT)
BEGIN
    DELETE FROM Authors WHERE authorID = p_authorID;
END //

DELIMITER ;

/* Add Genre */
DROP PROCEDURE IF EXISTS sp_insert_genre;
DELIMITER //
CREATE PROCEDURE sp_insert_genre(p_genreName VARCHAR(50))
BEGIN
    INSERT INTO Genres (genreName) VALUES (p_genreName);
END //
DELIMITER ;

/* Update Genre */
DROP PROCEDURE IF EXISTS sp_update_genre;
DELIMITER //
CREATE PROCEDURE sp_update_genre(p_genreID INT, p_genreName VARCHAR(50))
BEGIN
    UPDATE Genres SET genreName = p_genreName WHERE genreID = p_genreID;
END //
DELIMITER ;

/* Delete Genre */
DROP PROCEDURE IF EXISTS sp_delete_genre;
DELIMITER //
CREATE PROCEDURE sp_delete_genre(p_genreID INT)
BEGIN
    DELETE FROM Genres WHERE genreID = p_genreID;
END //
DELIMITER ;

/* Add Patron */
DROP PROCEDURE IF EXISTS sp_insert_patron;
DELIMITER //
CREATE PROCEDURE sp_insert_patron(
    p_libraryCardNumber VARCHAR(20),
    p_firstName VARCHAR(50),
    p_lastName VARCHAR(50),
    p_email VARCHAR(100),
    p_phone VARCHAR(12)
)
BEGIN
    INSERT INTO Patrons (libraryCardNumber, firstName, lastName, email, phone)
    VALUES (p_libraryCardNumber, p_firstName, p_lastName, p_email, p_phone);
END //
DELIMITER ;

/* Update Patron */
DROP PROCEDURE IF EXISTS sp_update_patron;
DELIMITER //
CREATE PROCEDURE sp_update_patron(
    p_patronID INT,
    p_libraryCardNumber VARCHAR(20),
    p_firstName VARCHAR(50),
    p_lastName VARCHAR(50),
    p_email VARCHAR(100),
    p_phone VARCHAR(12)
)
BEGIN
    UPDATE Patrons 
    SET libraryCardNumber = p_libraryCardNumber,
        firstName = p_firstName,
        lastName = p_lastName,
        email = p_email,
        phone = p_phone
    WHERE patronID = p_patronID;
END //
DELIMITER ;

/* Delete Patron */
DROP PROCEDURE IF EXISTS sp_delete_patron;
DELIMITER //
CREATE PROCEDURE sp_delete_patron(p_patronID INT)
BEGIN
    DELETE FROM Patrons WHERE patronID = p_patronID;
END //
DELIMITER ;

/* Add BookCopy */
DROP PROCEDURE IF EXISTS sp_insert_bookcopy;
DELIMITER //
CREATE PROCEDURE sp_insert_bookcopy(
    p_bookID INT,
    p_acquisitionDate DATE,
    p_condition VARCHAR(20),
    p_location VARCHAR(50),
    p_status VARCHAR(20)
)
BEGIN
    INSERT INTO BookCopies (bookID, acquisitionDate, `condition`, location, status)
    VALUES (p_bookID, p_acquisitionDate, p_condition, p_location, p_status);
END //
DELIMITER ;

/* Update BookCopy */
DROP PROCEDURE IF EXISTS sp_update_bookcopy;
DELIMITER //
CREATE PROCEDURE sp_update_bookcopy(
    p_copyID INT,
    p_bookID INT,
    p_acquisitionDate DATE,
    p_condition VARCHAR(20),
    p_location VARCHAR(50),
    p_status VARCHAR(20)
)
BEGIN
    UPDATE BookCopies 
    SET bookID = p_bookID,
        acquisitionDate = p_acquisitionDate,
        `condition` = p_condition,
        location = p_location,
        status = p_status
    WHERE copyID = p_copyID;
END //
DELIMITER ;

/* Delete BookCopy */
DROP PROCEDURE IF EXISTS sp_delete_bookcopy;
DELIMITER //
CREATE PROCEDURE sp_delete_bookcopy(p_copyID INT)
BEGIN
    DELETE FROM BookCopies WHERE copyID = p_copyID;
END //
DELIMITER ;

/* Add Loan */
DROP PROCEDURE IF EXISTS sp_insert_loan;
DELIMITER //
CREATE PROCEDURE sp_insert_loan(
    p_copyID INT,
    p_patronID INT,
    p_checkoutDate DATE,
    p_dueDate DATE,
    p_status ENUM('Active','Returned','Overdue','Lost')
)
BEGIN
    INSERT INTO Loans (copyID, patronID, checkoutDate, dueDate, status)
    VALUES (p_copyID, p_patronID, p_checkoutDate, p_dueDate, p_status);
END //
DELIMITER ;

/* Update Loan */
DROP PROCEDURE IF EXISTS sp_update_loan;
DELIMITER //
CREATE PROCEDURE sp_update_loan(
    p_loanID INT,
    p_returnDate DATE,
    p_lateFee DECIMAL(5,2),
    p_status ENUM('Active','Returned','Overdue','Lost')
)
BEGIN
    UPDATE Loans 
    SET returnDate = p_returnDate,
        lateFee = p_lateFee,
        status = p_status
    WHERE loanID = p_loanID;
END //
DELIMITER ;

/* Delete Loan */
DROP PROCEDURE IF EXISTS sp_delete_loan;
DELIMITER //
CREATE PROCEDURE sp_delete_loan(p_loanID INT)
BEGIN
    DELETE FROM Loans WHERE loanID = p_loanID;
END //
DELIMITER ;

/* Add BookAuthor relationship */
DROP PROCEDURE IF EXISTS sp_insert_bookauthor;
DELIMITER //
CREATE PROCEDURE sp_insert_bookauthor(p_bookID INT, p_authorID INT)
BEGIN
    INSERT INTO BookAuthors (bookID, authorID) VALUES (p_bookID, p_authorID);
END //
DELIMITER ;

/* Update BookAuthor relationship */
DROP PROCEDURE IF EXISTS sp_update_bookauthor;
DELIMITER //
CREATE PROCEDURE sp_update_bookauthor(
    p_bookID INT,
    p_old_authorID INT,
    p_new_authorID INT
)
BEGIN
    UPDATE BookAuthors 
    SET authorID = p_new_authorID 
    WHERE bookID = p_bookID AND authorID = p_old_authorID;
END //
DELIMITER ;

/* Delete BookAuthor relationship */
DROP PROCEDURE IF EXISTS sp_delete_bookauthor;
DELIMITER //
CREATE PROCEDURE sp_delete_bookauthor(p_bookID INT, p_authorID INT)
BEGIN
    DELETE FROM BookAuthors WHERE bookID = p_bookID AND authorID = p_authorID;
END //
DELIMITER ;

/* Add BookGenre relationship */
DROP PROCEDURE IF EXISTS sp_insert_bookgenre;
DELIMITER //
CREATE PROCEDURE sp_insert_bookgenre(p_bookID INT, p_genreID INT)
BEGIN
    INSERT INTO BookGenres (bookID, genreID) VALUES (p_bookID, p_genreID);
END //
DELIMITER ;

/* Update BookGenre relationship */
DROP PROCEDURE IF EXISTS sp_update_bookgenre;
DELIMITER //
CREATE PROCEDURE sp_update_bookgenre(
    p_bookID INT,
    p_old_genreID INT,
    p_new_genreID INT
)
BEGIN
    UPDATE BookGenres 
    SET genreID = p_new_genreID 
    WHERE bookID = p_bookID AND genreID = p_old_genreID;
END //
DELIMITER ;

/* Delete BookGenre relationship */
DROP PROCEDURE IF EXISTS sp_delete_bookgenre;
DELIMITER //
CREATE PROCEDURE sp_delete_bookgenre(p_bookID INT, p_genreID INT)
BEGIN
    DELETE FROM BookGenres WHERE bookID = p_bookID AND genreID = p_genreID;
END //
DELIMITER ;

/* Demo Delete */
DROP PROCEDURE IF EXISTS sp_delete_demo_loan;
DELIMITER //

CREATE PROCEDURE sp_delete_demo_loan()
BEGIN
    DELETE FROM Loans
    WHERE copyID = 2
      AND patronID = 1
      AND checkoutDate = '2026-02-01'
      AND status = 'Active'
    LIMIT 1;
END //

DELIMITER ;