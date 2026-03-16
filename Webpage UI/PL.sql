/* CS340 Group 46 Project - PL.sql */
   
/* Members: Son Thai Do Nguyen - Joshua Cicchinelli - Mauricio Marin Gutierrez */

/* PL - Procedures */

/* Reset */
DROP PROCEDURE IF EXISTS reset_library;

DELIMITER //

CREATE PROCEDURE reset_library()
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
    ('LC1003', 'Son', 'Nguyen', 'son.nguyen@email.com', '5415552002' );

    -- Authors
    INSERT INTO Authors (firstName, lastName, birthYear) VALUES
    ('J.K.', 'Rowling', 1965),
    ('Stephen', 'King', 1947);

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
END//

DELIMITER ;


/* Demo Delete */
DROP PROCEDURE IF EXISTS delete_demo_loan;
DELIMITER //

CREATE PROCEDURE delete_demo_loan()
BEGIN
    DELETE FROM Loans
    WHERE copyID = 2
      AND patronID = 1
      AND checkoutDate = '2026-02-01'
      AND status = 'Active'
    LIMIT 1;
END //

DELIMITER ;