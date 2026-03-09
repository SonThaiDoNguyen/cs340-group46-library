/* CS340 Project Step 2 - Group 46 */

/* DDL - Tables, Indexes, Stored Procedures */

/* 
Tables:
   - Books, BookCopies, Patrons, Loans, Authors, Genres
   - BookAuthors (junction), BookGenres (junction)
*/

SET FOREIGN_KEY_CHECKS = 0;
SET AUTOCOMMIT = 0;
START TRANSACTION;

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
COMMIT;