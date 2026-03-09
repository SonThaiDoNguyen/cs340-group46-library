// ########################################
// ########## SETUP

// Express
const express = require('express');
const app = express();
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static('public'));

const PORT = 1995;

// Database
const db = require('./database/db-connector');

// Handlebars
const { engine } = require('express-handlebars'); // Import express-handlebars engine
app.engine('.hbs', engine({ extname: '.hbs' })); // Create instance of handlebars
app.set('view engine', '.hbs'); // Use handlebars engine for *.hbs files.

// ########################################
// ########## ROUTE HANDLERS

// READ ROUTES
app.get('/', async function (req, res) {
    try {
        const resetSuccess = req.query.reset === 'success';
        res.render('home', { resetSuccess: resetSuccess }); // Render the home.hbs file with reset status
    } catch (error) {
        console.error('Error rendering page:', error);
        // Send a generic error message to the browser
        res.status(500).send('An error occurred while rendering the page.');
    }
});

app.get('/authors', async function (req, res) {
    try {
        // Get Data
        const query = 'SELECT authorID, firstName, lastName, birthYear FROM Authors;';
        // Returns [rows, fields]
        const [rows] = await db.query(query);
        res.render('authors', { authors: rows });
    } catch (error) {
        console.error('Error rendering page:', error);
        res.status(500).send('An error occurred while rendering the page.');
    }
});
    // Citation for the following:
    // Date: 2/19/2026
    // Adapted from Prompt: *insert lecture code* I need to add Sql sample data to this. Describe how I would do it*
    // Source URL: https://chatgpt.com/

app.get('/books', async function (req, res) {
    try {
        const query = `
            SELECT
                b.bookID,
                b.ISBN,
                b.title,
                b.publicationYear,
                b.publisher,
                b.bookMedia,
                COALESCE(GROUP_CONCAT(DISTINCT CONCAT(a.firstName, ' ', a.lastName) SEPARATOR ', '), 'None') AS authors,
                COALESCE(GROUP_CONCAT(DISTINCT g.genreName SEPARATOR ', '), 'None') AS genres
            FROM Books b
            LEFT JOIN BookAuthors ba ON b.bookID = ba.bookID
            LEFT JOIN Authors a ON ba.authorID = a.authorID
            LEFT JOIN BookGenres bg ON b.bookID = bg.bookID
            LEFT JOIN Genres g ON bg.genreID = g.genreID
            GROUP BY b.bookID, b.ISBN, b.title, b.publicationYear, b.publisher, b.bookMedia
            ORDER BY b.bookID;
        `;
        const [rows] = await db.query(query);
        res.render('books', { books: rows });
    } catch (error) {
        console.error('Error rendering books page:', error);
        res.status(500).send('An error occurred while rendering the page.');
    }
});    

app.get('/book_authors', async function (req, res) {
    try {
        const query = `
            SELECT
                ba.bookID,
                b.title,
                ba.authorID,
                CONCAT(a.firstName, ' ', a.lastName) AS authorName
            FROM BookAuthors ba
            JOIN Books b ON ba.bookID = b.bookID
            JOIN Authors a ON ba.authorID = a.authorID
            ORDER BY ba.bookID, ba.authorID;
        `;
        const [rows] = await db.query(query);
        res.render('book_authors', { book_authors: rows });
    } catch (error) {
        console.error('Error rendering book_authors page:', error);
        res.status(500).send('An error occurred while rendering the page.');
    }
});    

app.get('/book_copies', async function (req, res) {
    try {
        // Get BookCopies data with joined book titles
        const query = `
            SELECT bc.copyID, bc.bookID, b.title, bc.acquisitionDate, bc.\`condition\`, bc.location, bc.status
            FROM BookCopies bc
            JOIN Books b ON bc.bookID = b.bookID
            ORDER BY bc.copyID;
        `;
        const [rows] = await db.query(query);

        // Get books for dropdown
        const booksQuery = 'SELECT bookID, title FROM Books ORDER BY title;';
        const [books] = await db.query(booksQuery);

        res.render('book_copies', { book_copies: rows, books: books, copies: rows });
    } catch (error) {
        console.error('Error rendering page:', error);
        res.status(500).send('An error occurred while rendering the page.');
    }
});      

app.get('/book_genres', async function (req, res) {
    try {
        const query = `
            SELECT
                bg.bookID,
                b.title,
                bg.genreID,
                g.genreName
            FROM BookGenres bg
            JOIN Books b ON bg.bookID = b.bookID
            JOIN Genres g ON bg.genreID = g.genreID
            ORDER BY bg.bookID, bg.genreID;
        `;
        const [rows] = await db.query(query);
        res.render('book_genres', { book_genres: rows });
    } catch (error) {
        console.error('Error rendering book_genres page:', error);
        res.status(500).send('An error occurred while rendering the page.');
    }
});  

app.get('/genres', async function (req, res) {
    try {
        // Get Data
        const query = 'SELECT genreID, genreName FROM Genres;';
        // Returns [rows, fields]
        const [rows] = await db.query(query);
        res.render('genres', { genres: rows });
    } catch (error) {
        console.error('Error rendering page:', error);
        res.status(500).send('An error occurred while rendering the page.');
    }
}); 

app.get('/loans', async function (req, res) {
    try {
        // Get Data
        const query = 'SELECT loanID, copyID, patronID, checkoutDate, dueDate, returnDate, lateFee, status FROM Loans;';
        // Returns [rows, fields]
        const [rows] = await db.query(query);
        const deletedDemo = req.query.deleted === 'demo';
        res.render('loans', { loans: rows, deletedDemo: deletedDemo });
    } catch (error) {
        console.error('Error rendering page:', error);
        res.status(500).send('An error occurred while rendering the page.');
    }
}); 

app.get('/patrons', async function (req, res) {
    try {
        // Get Data
        const query = 'SELECT patronID, libraryCardNumber, firstName, lastName, email, phone FROM Patrons;';
        // Returns [rows, fields]
        const [rows] = await db.query(query);
        res.render('patrons', { patrons: rows });
    } catch (error) {
        console.error('Error rendering page:', error);
        res.status(500).send('An error occurred while rendering the page.');
    }
}); 

// ============ AUTHORS CUD ==============
// CREATE
app.post('/authors/add', async function (req, res) {
    try {
        const { firstName, lastName, birthYear } = req.body;
        const query = `INSERT INTO Authors (firstName, lastName, birthYear) VALUES (?, ?, ?);`;
        await db.query(query, [firstName, lastName, birthYear || null]);
        res.redirect('/authors');
    } catch (error) {
        console.error('Error inserting author:', error);
        res.status(500).send('An error occurred while inserting the author.');
    }
});

// UPDATE
app.post('/authors/update', async function (req, res) {
    try {
        const { authorID, firstName, lastName, birthYear } = req.body;
        const query = `UPDATE Authors SET firstName = ?, lastName = ?, birthYear = ? WHERE authorID = ?;`;
        await db.query(query, [firstName, lastName, birthYear || null, authorID]);
        res.redirect('/authors');
    } catch (error) {
        console.error('Error updating author:', error);
        res.status(500).send('An error occurred while updating the author.');
    }
});

// DELETE
app.post('/authors/delete', async function (req, res) {
    try {
        const { authorID } = req.body;
        const query = `DELETE FROM Authors WHERE authorID = ?;`;
        await db.query(query, [authorID]);
        res.redirect('/authors');
    } catch (error) {
        console.error('Error deleting author:', error);
        res.status(500).send('Could not delete author. They may be referenced by another table.');
    }
});

// ============ BOOKS CUD ==============
// CREATE
app.post('/books/add', async function (req, res) {
    try {
        const { ISBN, title, publicationYear, publisher, bookMedia } = req.body;
        const query = `INSERT INTO Books (ISBN, title, publicationYear, publisher, bookMedia) VALUES (?, ?, ?, ?, ?);`;
        await db.query(query, [ISBN, title, publicationYear || null, publisher || null, bookMedia]);
        res.redirect('/books');
    } catch (error) {
        console.error('Error inserting book:', error);
        res.status(500).send('An error occurred while inserting the book.');
    }
});

// UPDATE
app.post('/books/update', async function (req, res) {
    try {
        const { bookID, ISBN, title, publicationYear, publisher, bookMedia } = req.body;
        const query = `UPDATE Books SET ISBN = ?, title = ?, publicationYear = ?, publisher = ?, bookMedia = ? WHERE bookID = ?;`;
        await db.query(query, [ISBN, title, publicationYear || null, publisher || null, bookMedia, bookID]);
        res.redirect('/books');
    } catch (error) {
        console.error('Error updating book:', error);
        res.status(500).send('An error occurred while updating the book.');
    }
});

// DELETE
app.post('/books/delete', async function (req, res) {
    try {
        const { bookID } = req.body;
        const query = `DELETE FROM Books WHERE bookID = ?;`;
        await db.query(query, [bookID]);
        res.redirect('/books');
    } catch (error) {
        console.error('Error deleting book:', error);
        res.status(500).send('Could not delete book. It may have associated records.');
    }
});

// ============ BOOKAUTHORS CUD ==============
// CREATE
app.post('/book_authors/add', async function (req, res) {
    try {
        const { bookID, authorID } = req.body;
        const query = `INSERT INTO BookAuthors (bookID, authorID) VALUES (?, ?);`;
        await db.query(query, [bookID, authorID]);
        res.redirect('/book_authors');
    } catch (error) {
        console.error('Error inserting book-author relationship:', error);
        res.status(500).send('An error occurred while inserting the relationship.');
    }
});

// UPDATE
app.post('/book_authors/update', async function (req, res) {
    try {
        const { bookID, old_authorID, new_authorID } = req.body;
        const query = `UPDATE BookAuthors SET authorID = ? WHERE bookID = ? AND authorID = ?;`;
        await db.query(query, [new_authorID, bookID, old_authorID]);
        res.redirect('/book_authors');
    } catch (error) {
        console.error('Error updating book-author relationship:', error);
        res.status(500).send('An error occurred while updating the relationship.');
    }
});

// DELETE
app.post('/book_authors/delete', async function (req, res) {
    try {
        const { bookID, authorID } = req.body;
        const query = `DELETE FROM BookAuthors WHERE bookID = ? AND authorID = ?;`;
        await db.query(query, [bookID, authorID]);
        res.redirect('/book_authors');
    } catch (error) {
        console.error('Error deleting book-author relationship:', error);
        res.status(500).send('An error occurred while deleting the relationship.');
    }
});

// ============ BOOKGENRES CUD ==============
// CREATE
app.post('/book_genres/add', async function (req, res) {
    try {
        const { bookID, genreID } = req.body;
        const query = `INSERT INTO BookGenres (bookID, genreID) VALUES (?, ?);`;
        await db.query(query, [bookID, genreID]);
        res.redirect('/book_genres');
    } catch (error) {
        console.error('Error inserting book-genre relationship:', error);
        res.status(500).send('An error occurred while inserting the relationship.');
    }
});

// UPDATE
app.post('/book_genres/update', async function (req, res) {
    try {
        const { bookID, old_genreID, new_genreID } = req.body;
        const query = `UPDATE BookGenres SET genreID = ? WHERE bookID = ? AND genreID = ?;`;
        await db.query(query, [new_genreID, bookID, old_genreID]);
        res.redirect('/book_genres');
    } catch (error) {
        console.error('Error updating book-genre relationship:', error);
        res.status(500).send('An error occurred while updating the relationship.');
    }
});

// DELETE
app.post('/book_genres/delete', async function (req, res) {
    try {
        const { bookID, genreID } = req.body;
        const query = `DELETE FROM BookGenres WHERE bookID = ? AND genreID = ?;`;
        await db.query(query, [bookID, genreID]);
        res.redirect('/book_genres');
    } catch (error) {
        console.error('Error deleting book-genre relationship:', error);
        res.status(500).send('An error occurred while deleting the relationship.');
    }
});

// ============ BOOKCOPIES CUD ==============
// CREATE
app.post('/book_copies/add', async function (req, res) {
    try {
        const { bookID, acquisitionDate, condition, location, status } = req.body;
        const query = `INSERT INTO BookCopies (bookID, acquisitionDate, \`condition\`, location, status) VALUES (?, ?, ?, ?, ?);`;
        await db.query(query, [bookID, acquisitionDate, condition, location, status]);
        res.redirect('/book_copies');
    } catch (error) {
        console.error('Error inserting book copy:', error);
        res.status(500).send('An error occurred while inserting the book copy.');
    }
});

// UPDATE
app.post('/book_copies/update', async function (req, res) {
    try {
        const { copyID, bookID, acquisitionDate, condition, location, status } = req.body;
        const query = `UPDATE BookCopies SET bookID = ?, acquisitionDate = ?, \`condition\` = ?, location = ?, status = ? WHERE copyID = ?;`;
        await db.query(query, [bookID, acquisitionDate, condition, location, status, copyID]);
        res.redirect('/book_copies');
    } catch (error) {
        console.error('Error updating book copy:', error);
        res.status(500).send('An error occurred while updating the book copy.');
    }
});

// DELETE
app.post('/book_copies/delete', async function (req, res) {
    try {
        const { copyID } = req.body;
        const query = `DELETE FROM BookCopies WHERE copyID = ?;`;
        await db.query(query, [copyID]);
        res.redirect('/book_copies');
    } catch (error) {
        console.error('Error deleting book copy:', error);
        res.status(500).send('Could not delete book copy. It may have associated loans.');
    }
});

// ============ GENRES CUD ==============
// CREATE
app.post('/genres/add', async function (req, res) {
    try {
        const { genreName } = req.body;
        const query = `INSERT INTO Genres (genreName) VALUES (?);`;
        await db.query(query, [genreName]);
        res.redirect('/genres');
    } catch (error) {
        console.error('Error inserting genre:', error);
        res.status(500).send('An error occurred while inserting the genre.');
    }
});

// UPDATE
app.post('/genres/update', async function (req, res) {
    try {
        const { genreID, genreName } = req.body;
        const query = `UPDATE Genres SET genreName = ? WHERE genreID = ?;`;
        await db.query(query, [genreName, genreID]);
        res.redirect('/genres');
    } catch (error) {
        console.error('Error updating genre:', error);
        res.status(500).send('An error occurred while updating the genre.');
    }
});

// DELETE
app.post('/genres/delete', async function (req, res) {
    try {
        const { genreID } = req.body;
        const query = `DELETE FROM Genres WHERE genreID = ?;`;
        await db.query(query, [genreID]);
        res.redirect('/genres');
    } catch (error) {
        console.error('Error deleting genre:', error);
        res.status(500).send('Could not delete genre. It may be associated with books.');
    }
});

// ============ PATRONS CUD ==============
// CREATE
app.post('/patrons/add', async function (req, res) {
    try {
        const { libraryCardNumber, firstName, lastName, email, phone } = req.body;
        const query = `INSERT INTO Patrons (libraryCardNumber, firstName, lastName, email, phone) VALUES (?, ?, ?, ?, ?);`;
        await db.query(query, [libraryCardNumber, firstName, lastName, email, phone || null]);
        res.redirect('/patrons');
    } catch (error) {
        console.error('Error inserting patron:', error);
        res.status(500).send('An error occurred while inserting the patron.');
    }
});

// UPDATE
app.post('/patrons/update', async function (req, res) {
    try {
        const { patronID, libraryCardNumber, firstName, lastName, email, phone } = req.body;
        const query = `UPDATE Patrons SET libraryCardNumber = ?, firstName = ?, lastName = ?, email = ?, phone = ? WHERE patronID = ?;`;
        await db.query(query, [libraryCardNumber, firstName, lastName, email, phone || null, patronID]);
        res.redirect('/patrons');
    } catch (error) {
        console.error('Error updating patron:', error);
        res.status(500).send('An error occurred while updating the patron.');
    }
});

// DELETE
app.post('/patrons/delete', async function (req, res) {
    try {
        const { patronID } = req.body;
        const query = `DELETE FROM Patrons WHERE patronID = ?;`;
        await db.query(query, [patronID]);
        res.redirect('/patrons');
    } catch (error) {
        console.error('Error deleting patron:', error);
        res.status(500).send('Could not delete patron. They may have active loans.');
    }
});

// ============ LOANS CUD ==============
// CREATE
app.post('/loans/add', async function (req, res) {
    try {
        const { copyID, patronID, checkoutDate, dueDate, status } = req.body;
        const query = `INSERT INTO Loans (copyID, patronID, checkoutDate, dueDate, status) VALUES (?, ?, ?, ?, ?);`;
        await db.query(query, [copyID, patronID, checkoutDate, dueDate, status]);
        res.redirect('/loans');
    } catch (error) {
        console.error('Error inserting loan:', error);
        res.status(500).send('An error occurred while inserting the loan.');
    }
});

// UPDATE
app.post('/loans/update', async function (req, res) {
    try {
        const { loanID, returnDate, lateFee, status } = req.body;
        const query = `UPDATE Loans SET returnDate = ?, lateFee = ?, status = ? WHERE loanID = ?;`;
        await db.query(query, [returnDate || null, lateFee || 0, status, loanID]);
        res.redirect('/loans');
    } catch (error) {
        console.error('Error updating loan:', error);
        res.status(500).send('An error occurred while updating the loan.');
    }
});

// DELETE
app.post('/loans/delete', async function (req, res) {
    try {
        const { loanID } = req.body;
        const query = `DELETE FROM Loans WHERE loanID = ?;`;
        await db.query(query, [loanID]);
        res.redirect('/loans');
    } catch (error) {
        console.error('Error deleting loan:', error);
        res.status(500).send('An error occurred while deleting the loan.');
    }
});

// ============ RESET Routes ===============
app.get('/reset-database', async function (req, res) {
    try {
        // Call the stored procedure to reset the database
        const query = 'CALL reset_library();'
        await db.query(query);
        
        // Redirect to home page with success message
        res.redirect('/?reset=success');
    } catch (error) {
        console.error("Error resetting database:", error);
        res.status(500).send("An error occurred while resetting the database.");
    }
});

// Demo: delete a specific loan to show RESET works
app.get('/delete-demo-loan', async function (req, res) {
    try {
        // Call the stored procedure to delete the demo loan
        const query = 'CALL delete_demo_loan();';
        await db.query(query);

        // Redirect to loans page to show the change
        res.redirect('/loans?deleted=demo');
    } catch (error) {
        console.error("Error deleting demo loan:", error);
        res.status(500).send("An error occurred while deleting the demo loan.");
    }
})

// ########################################
// ########## LISTENER

app.listen(PORT, function () {
    console.log(
        'Express started on http://localhost:' +
            PORT +
            '; press Ctrl-C to terminate.'
    );
});