/* CS340 Group 46 Project Step 3 — DML */
   
/* Members: Son Thai Do Nguyen - Joshua Cicchinelli - Mauricio Marin Gutierrez
   Placeholder:
   Variables are denoted with @LikeThisInput to represent values
   that will be supplied by backend code later. */

/* BOOKS */

-- Browse Books
SELECT bookID, ISBN, title, publicationYear, publisher, bookMedia
FROM Books
ORDER BY bookID;

-- Add a Book
INSERT INTO Books (ISBN, title, publicationYear, publisher, bookMedia)
VALUES (@isbnInput, @titleInput, @publicationYearInput, @publisherInput, @bookMediaInput);

-- Get a Book
SELECT bookID, ISBN, title, publicationYear, publisher, bookMedia
FROM Books
WHERE bookID = @bookIDInput;

-- Update a Book
UPDATE Books
SET ISBN = @isbnInput,
    title = @titleInput,
    publicationYear = @publicationYearInput,
    publisher = @publisherInput,
    bookMedia = @bookMediaInput
WHERE bookID = @bookIDInput;

-- Delete a Book (CASCADE to BookCopies, BookAuthors, BookGenres)
DELETE FROM Books
WHERE bookID = @bookIDInput;

/* PATRONS */

-- Browse Patrons
SELECT patronID, libraryCardNumber, firstName, lastName, email, phone
FROM Patrons
ORDER BY patronID;

-- Add a Patron
INSERT INTO Patrons (libraryCardNumber, firstName, lastName, email, phone)
VALUES (@libraryCardNumberInput, @firstNameInput, @lastNameInput, @emailInput, @phoneInput);

-- Get a Patron
SELECT patronID, libraryCardNumber, firstName, lastName, email, phone
FROM Patrons
WHERE patronID = @patronIDInput;

-- Update a Patron
UPDATE Patrons
SET libraryCardNumber = @libraryCardNumberInput,
    firstName = @firstNameInput,
    lastName = @lastNameInput,
    email = @emailInput,
    phone = @phoneInput
WHERE patronID = @patronIDInput;

DELETE FROM Patrons
WHERE patronID = @patronIDInput;

/* AUTHORS */

-- Browse Authors
SELECT authorID, firstName, lastName, birthYear
FROM Authors
ORDER BY authorID;

-- Add an Author
INSERT INTO Authors (firstName, lastName, birthYear)
VALUES (@firstNameInput, @lastNameInput, @birthYearInput);

-- Get an Author
SELECT authorID, firstName, lastName, birthYear
FROM Authors
WHERE authorID = @authorIDInput;

-- Update an Author
UPDATE Authors
SET firstName = @firstNameInput,
    lastName = @lastNameInput,
    birthYear = @birthYearInput
WHERE authorID = @authorIDInput;

-- Delete an Author
DELETE FROM Authors
WHERE authorID = @authorIDInput;

/* GENRES */

-- Browse Genres
SELECT genreID, genreName
FROM Genres
ORDER BY genreID;

-- Add a Genre
INSERT INTO Genres (genreName)
VALUES (@genreNameInput);

-- Get a Genre
SELECT genreID, genreName
FROM Genres
WHERE genreID = @genreIDInput;

-- Update a Genre
UPDATE Genres
SET genreName = @genreNameInput
WHERE genreID = @genreIDInput;

-- Delete a Genre
DELETE FROM Genres
WHERE genreID = @genreIDInput;

/* BOOKCOPIES */

-- Browse BookCopies
SELECT bc.copyID, bc.bookID, b.title, bc.acquisitionDate, bc.`condition`, bc.location, bc.status
FROM BookCopies AS bc
JOIN Books AS b ON bc.bookID = b.bookID
ORDER BY bc.copyID;

-- Books drop down for selecting bookID
SELECT bookID, title
FROM Books
ORDER BY title;

-- Add a BookCopy
INSERT INTO BookCopies (bookID, acquisitionDate, `condition`, location, status)
VALUES (@bookIDInput, @acquisitionDateInput, @conditionInput, @locationInput, @statusInput);

-- Get a BookCopy
SELECT copyID, bookID, acquisitionDate, `condition`, location, status
FROM BookCopies
WHERE copyID = @copyIDInput;

-- Update a BookCopy
UPDATE BookCopies
SET bookID = @bookIDInput,
    acquisitionDate = @acquisitionDateInput,
    `condition` = @conditionInput,
    location = @locationInput,
    status = @statusInput
WHERE copyID = @copyIDInput;

-- Delete a BookCopy
DELETE FROM BookCopies
WHERE copyID = @copyIDInput;

/* LOANS */

-- Browse Loans
SELECT l.loanID,
       l.copyID, b.title,
       l.patronID, p.firstName, p.lastName,
       l.checkoutDate, l.dueDate, l.returnDate,
       l.lateFee, l.status
FROM Loans AS l
JOIN BookCopies AS bc ON l.copyID = bc.copyID
JOIN Books AS b ON bc.bookID = b.bookID
JOIN Patrons AS p ON l.patronID = p.patronID
ORDER BY l.loanID;

-- Copies drop down for selecting copyID
SELECT bc.copyID, b.title, bc.status
FROM BookCopies AS bc
JOIN Books AS b ON bc.bookID = b.bookID
ORDER BY bc.copyID;

-- Patrons drop down for selecting patronID
SELECT patronID, firstName, lastName
FROM Patrons
ORDER BY lastName, firstName;

-- Add a Loan
INSERT INTO Loans (copyID, patronID, checkoutDate, dueDate, returnDate, lateFee, status)
VALUES (@copyIDInput, @patronIDInput, @checkoutDateInput, @dueDateInput, @returnDateInput, @lateFeeInput, @statusInput);

-- Get a Loan
SELECT loanID, copyID, patronID, checkoutDate, dueDate, returnDate, lateFee, status
FROM Loans
WHERE loanID = @loanIDInput;

-- Update a Loan
UPDATE Loans
SET copyID = @copyIDInput,
    patronID = @patronIDInput,
    checkoutDate = @checkoutDateInput,
    dueDate = @dueDateInput,
    returnDate = @returnDateInput,
    lateFee = @lateFeeInput,
    status = @statusInput
WHERE loanID = @loanIDInput;

-- Delete a Loan
DELETE FROM Loans
WHERE loanID = @loanIDInput;

/* BookAuthors (junction) */

-- Browse BookAuthors (joined to show Book + Author)
SELECT ba.bookID, b.title, ba.authorID, a.firstName, a.lastName
FROM BookAuthors AS ba
JOIN Books AS b ON ba.bookID = b.bookID
JOIN Authors AS a ON ba.authorID = a.authorID
ORDER BY ba.bookID, ba.authorID;

-- Dropdowns
SELECT bookID, title FROM Books ORDER BY title;
SELECT authorID, firstName, lastName FROM Authors ORDER BY lastName, firstName;

INSERT INTO BookAuthors (bookID, authorID)
VALUES (@bookIDInput, @authorIDInput);

UPDATE BookAuthors
SET authorID = @newAuthorIDInput
WHERE bookID = @bookIDInput AND authorID = @oldAuthorIDInput;

DELETE FROM BookAuthors
WHERE bookID = @bookIDInput AND authorID = @authorIDInput;

/* BookGenres (junction) */

-- Browse BookGenres (joined to show Book + Genre)
SELECT bg.bookID, b.title, bg.genreID, g.genreName
FROM BookGenres AS bg
JOIN Books AS b ON bg.bookID = b.bookID
JOIN Genres AS g ON bg.genreID = g.genreID
ORDER BY bg.bookID, bg.genreID;

-- Dropdown
SELECT bookID, title FROM Books ORDER BY title;
SELECT genreID, genreName FROM Genres ORDER BY genreName;

INSERT INTO BookGenres (bookID, genreID)
VALUES (@bookIDInput, @genreIDInput);

UPDATE BookGenres
SET genreID = @newGenreIDInput
WHERE bookID = @bookIDInput AND genreID = @oldGenreIDInput;

DELETE FROM BookGenres
WHERE bookID = @bookIDInput AND genreID = @genreIDInput;