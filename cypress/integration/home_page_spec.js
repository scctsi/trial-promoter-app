describe('The Home Page', function() {
  it('successfully loads', function() {
    // there is a before action that creates a user for all tests
    // so this starts at the index page, rather than the login page
    cy.visit('localhost:3000/')

    cy.get('[data-method=delete]').should('contain', 'Logout')

    cy.get('[data-cy=email]').should('contain', 'faker@faker.com')
  })
})

describe('The new experiment page', function () {
  it('restricts a user from creating a new experiment', function () {

    cy.visit('localhost:3000/experiments/new')
    cy.get('[data-cy=unauthorized]').should('contain', 'You are not authorized to perform this action.')
    cy.get('[data-cy=home]').should('contain', 'Home')
  })
})