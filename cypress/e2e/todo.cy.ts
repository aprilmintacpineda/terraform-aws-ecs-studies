import { faker } from '@faker-js/faker';

/**
 * NOTE from the author:
 * I am not a QA automation tester, I implemented these because I needed something to run in CI/CD
 */

const todo = faker.lorem.lines(1);

describe('Todos management', () => {
  beforeEach(() => {
    cy.intercept('GET', '/trpc/listTodos*').as('listTodos');
    cy.intercept('POST', '/trpc/completeTodo*').as('completeTodo');
    cy.intercept('POST', '/trpc/deleteTodo*').as('deleteTodo');
  });

  it('create new todo', () => {
    cy.visit('')
      .wait('@listTodos')
      .get('[data-testid="create-todo-input-text"]')
      .type(`${todo}{enter}`)
      .should('be.disabled')
      .wait('@listTodos')
      .get('[data-testid="todo-list"]')
      .should('contain.text', todo)
      .get('[data-testid="create-todo-input-text"]')
      .should('be.empty');
  });

  it('should have todo complete button', () => {
    cy.visit('')
      .wait('@listTodos')
      .get('[data-testid="create-todo-input-text"]')
      .type(`${todo}{enter}`)
      .wait('@listTodos')
      .get('[data-testid="todo"]')
      .contains('Consequuntur exercitationem dicta.')
      .parent()
      .within(() => {
        cy.get('[data-testid="todo-complete"]').should('exist');
      });
  });

  it('should not have todo delete button', () => {
    cy.visit('')
      .wait('@listTodos')
      .get('[data-testid="create-todo-input-text"]')
      .type(`${todo}{enter}`)
      .wait('@listTodos')
      .get('[data-testid="todo"]')
      .contains(todo)
      .parent()
      .within(() => {
        cy.get('[data-testid="todo-delete"]').should('not.exist');
      });
  });

  it('be able to mark as done', () => {
    cy.visit('')
      .wait('@listTodos')
      .get('[data-testid="todo"]')
      .contains(todo)
      .parent()
      .within(() => {
        cy.get('[data-testid="todo-complete"]')
          .click()
          .should('be.disabled')
          .wait('@completeTodo')
          .get('[data-testid="todo-delete"]')
          .should('exist');
      });
  });

  it('not have complete todo button when todo has been completed', () => {
    cy.visit('')
      .wait('@listTodos')
      .get('[data-testid="todo"]')
      .contains(todo)
      .parent()
      .within(() => {
        cy.get('[data-testid="todo-complete"]').should('not.exist');
      });
  });

  it('be able to delete todo', () => {
    cy.visit('');

    cy.wait('@listTodos');

    const todoElement = cy
      .get('[data-testid="todo"]')
      .contains(todo)
      .parent();

    todoElement.within(() => {
      cy.get('[data-testid="todo-delete"]')
        .click()
        .should('be.disabled');

      cy.wait('@deleteTodo');
      cy.wait('@listTodos');

      // important, seems cypress is too eager to test that it runs the next command even though the UI hasn't updated yet.
      cy.wait(50);

      todoElement.should('not.exist');
    });
  });
});
