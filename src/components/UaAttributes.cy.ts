import UaAttributes from './UaAttributes.vue'

describe('<AuthForm/>', () => {
  it('should mount empty', () => {
    cy.mount(UaAttributes, {
      props: {
        attributes: [
          {
            name: 'DisplayName',
            attributeId: 13,
            value: 'RootFolder'
          },
          {
            name: 'NodeClass',
            attributeId: 1,
            value: 'Object'
          }
        ]
      }
    })

    cy.get('table.table-node-attributes').should('exist')
    cy.get('table.table-node-attributes >').should('have.length', 2)
  })
})
