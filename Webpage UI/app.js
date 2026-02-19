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
        res.render('home'); // Render the home.hbs file
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
        // Get Data
        const query = 'SELECT bookID, ISBN, title, publicationYear, publisher, bookMedia FROM Books;';
        // Returns [rows, fields]
        const [rows] = await db.query(query);
        res.render('books', { books: rows });
    } catch (error) {
        console.error('Error rendering page:', error);
        res.status(500).send('An error occurred while rendering the page.');
    }
});    

app.get('/book_authors', async function (req, res) {
    try {
        // Get Data
        const query = 'SELECT bookID, authorID FROM BookAuthors;';
        // Returns [rows, fields]
        const [rows] = await db.query(query);
        res.render('book_authors', { book_authors: rows });
    } catch (error) {
        console.error('Error rendering page:', error);
        res.status(500).send('An error occurred while rendering the page.');
    }
});    

app.get('/book_copies', async function (req, res) {
    try {
        // Get Data
        const query = 'SELECT bookID, acquisitionDate, `condition`, location, status FROM BookCopies;';
        // Returns [rows, fields]
        const [rows] = await db.query(query);
        res.render('book_copies', { book_copies: rows });
    } catch (error) {
        console.error('Error rendering page:', error);
        res.status(500).send('An error occurred while rendering the page.');
    }
});    

app.get('/book_genres', async function (req, res) {
    try {
        // Get Data
        const query = 'SELECT bookID, genreID FROM BookGenres;';
        // Returns [rows, fields]
        const [rows] = await db.query(query);
        res.render('book_genres', { book_genres: rows });
    } catch (error) {
        console.error('Error rendering page:', error);
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
        res.render('loans', { loans: rows });
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

// ########################################
// ########## LISTENER

app.listen(PORT, function () {
    console.log(
        'Express started on http://localhost:' +
            PORT +
            '; press Ctrl-C to terminate.'
    );
});