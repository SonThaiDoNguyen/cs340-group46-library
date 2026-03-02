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
        const query = 'SELECT copyID, bookID, acquisitionDate, `condition`, location, status FROM BookCopies;';
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

// INSERT Routes
app.post('/authors', async function (req, res) {
  try {
    const { firstName, lastName, birthYear } = req.body;

    const query = `
      INSERT INTO Authors (firstName, lastName, birthYear)
      VALUES (?, ?, ?);
    `;
    await db.query(query, [firstName, lastName, birthYear || null]);

    res.redirect('/authors');
  } catch (error) {
    console.error('Error inserting author:', error);
    res.status(500).send('An error occurred while inserting the author.');
  }
});

// UPDATE Routes
app.post('/authors/update', async function (req, res) {
  try {
    const { authorID, firstName, lastName, birthYear } = req.body;

    const query = `
      UPDATE Authors
      SET firstName = ?, lastName = ?, birthYear = ?
      WHERE authorID = ?;
    `;
    await db.query(query, [firstName, lastName, birthYear || null, authorID]);

    res.redirect('/authors');
  } catch (error) {
    console.error('Error updating author:', error);
    res.status(500).send('An error occurred while updating the author.');
  }
});

// DELETE Routes
app.post('/authors/delete', async function (req, res) {
  try {
    const { authorID } = req.body;

    const query = `DELETE FROM Authors WHERE authorID = ?;`;
    await db.query(query, [authorID]);

    res.redirect('/authors');
  } catch (error) {
    console.error('Error deleting author:', error);
    res.status(500).send(
      'Could not delete author. They may be referenced by another table (like BookAuthors).'
    );
  }
});

// RESET Routes
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