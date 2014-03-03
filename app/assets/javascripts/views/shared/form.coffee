class Visio.Views.Form extends Backbone.View

  @include Visio.Mixins.Modal

  template: HAML['shared/form']

  isSchemaInit: false

  initialize: (options) ->
    @schema = $.extend {}, @model.schema
    @parent = options.parent
    @nestedForms = {}
    @isModal = options.isModal

    @initModal() if @isModal

  initSchema: =>
    @original = @model.toJSON()
    @fields = new Visio.Collections.FormField()

    _.each @schema, (field) =>
      formField = new Visio.Models.FormField field
      @fields.add formField
      switch field.formElement
        when 'list'
          @nestedForms[field.name] = {}



    @isSchemaInit = true

    _.each @schema, (field) =>
      switch field.type
        when 'collection'
          @model.set field.name, field.collection() unless @model.get(field.name)?
          formField = @fields.findWhere { name: field.name }
          formField.setSelected @model.get(field.name).pluck 'id'
          formField.on 'change:selected', @render, @


    @fields.each (field) =>
      @nestedTrigger 'initialize', field

    @nestedTrigger 'initialize'

  events:
    'change .visio-checkbox input': 'onChange'
    'keyup input': 'onKeyup'
    'keyup textarea': 'onKeyup'
    'click .nested-item': 'onClickNestedItem'
    'click .nested-item-add': 'onAddNestedItem'
    'click .save': 'saveAndClose'
    'click .close': 'close'
    'click .nested-delete': 'onDeleteNestedItem'

  render: ->
    console.error 'Must call initSchema before rendering' unless @isSchemaInit
    @$el.html @template { schema: @schema }

    # Render child views
    for name, value of @nestedForms
      for id, view of @nestedForms[name]
        $('body').append view.render().el if view?

    _.each @schema, (field) =>
      formField = @fields.findWhere { name: field.name }
      @$el.find(".form-#{field.name}").html HAML["shared/form_parts/#{field.formElement}"]({
        modelField: @model.get(field.name),
        formField: formField })

    @nestedTrigger 'rendered'
    console.log @model.get('strategy_objectives')
    @

  onClickNestedItem: (e) ->
    $target = $(e.currentTarget)
    name = $target.attr 'data-name'
    id = $target.attr 'data-id'

    field = @fields.findWhere { name: name }
    model = @model.get(name).get id

    console.error 'Unable to find associated model' unless model

    @nestedItem model

  onDeleteNestedItem: (e) ->
    e.preventDefault()
    e.stopPropagation()

    $target = $(e.currentTarget)
    $item = $target.closest '.nested-item'

    name = $item.attr 'data-name'
    field = @fields.findWhere { name: name }
    collection = @model.get(name)
    id = $item.attr 'data-id'

    nestedModel = collection.get id

    collection.remove nestedModel
    @render()
    @nestedTrigger 'remove', field

  onAddNestedItem: (e) ->
    e.preventDefault()
    e.stopPropagation()

    $target = $(e.currentTarget)
    name = $target.attr 'data-name'
    field = @fields.findWhere { name: name }

    @nestedItem field.get('model')()

  onKeyup: (e) ->
    e.stopPropagation()
    $target = $(e.currentTarget)

    name = $target.attr 'data-name'
    field = @fields.findWhere { name: name }

    @change name, field, $target.val()

  onChange: (e) ->
    e.stopPropagation()

    $target = $(e.currentTarget)

    name = $target.attr 'data-name'
    id = $target.attr 'data-id'
    field = @fields.findWhere { name: name }

    # Get value based what type of form element it is
    value = $target.is ':checked'

    @change name, field, value, id

  change: (name, field, value, id) ->
    # Add a bit of extra information based on the type of field
    switch field.get 'type'
      when 'collection'
        model = @model.get(name).get id
        field.selected id, value if field.get('formElement') is 'checkboxes'

        @nestedTrigger 'change', field, value, model
      when 'string'
        @model.set name, value
        @nestedTrigger 'change', field, value

  nestedTrigger: (eventName, field, args...) =>
    eventArgs = [@, @model]


    if field?
      eventArgs.push field
      eventArgs.push @model.get(field.get('name'))

    eventArgs = eventArgs.concat args

    event = [eventName]
    event.push field.get 'name' if field?
    @trigger.apply @, [event.join(':')].concat(eventArgs)

    if @parent?
      eventArgs.unshift @parent
      parentEvent = [eventName, @model.name.plural]
      parentEvent.push field.get('name') if field?

      @parent.trigger.apply @parent, [parentEvent.join(':')].concat(eventArgs)

      # If there's a parent we want to change form to the nested form for event
      eventArgs[0] = @


  nestedItem: (model) ->
    id = model.id || model.cid
    @nestedForms[model.name.plural][id] = new Visio.Views.Form
      model: model
      parent: @
      isModal: true

    @nestedForms[model.name.plural][id].initSchema()

  # Returns model with new changes, or reverts back to old model
  commit: (save = false) =>
    @fields.each (field) =>
      name = field.get 'name'

      if save
        switch field.get 'formElement'
          when 'checkboxes'
            toCommit = []
            @model.get(name).each (item) ->
              toCommit.push item if field.selected item.id
            @model.get(name).reset toCommit
          when 'text'
            @model.set name, @$el.find(".form-field.form-#{name} input").val()
          when 'textarea'
            @model.set name, @$el.find(".form-field.form-#{name} textarea").val()

      else
        switch field.get 'formElement'
          when 'checkboxes', 'list' then @model.get(name).reset @original[name]
          when 'text', 'textarea' then @model.set name, @original[name]

    @model.toJSON()

  saveAndClose: =>
    @close true

  close: (save = false) =>

    if @parent? and save
      @parent.model.get(@model.name.plural).add @model
      delete @parent.nestedForms[@model.name.plural][@model.id || @model.cid]

    json = @commit save
    for name, value of @nestedForms
     for id, view of @nestedForms[name]
       @nestedForms[name][id].close(save)

    @nestedTrigger 'close'
    @nestedTrigger 'save' if save
    @unbind()
    @remove()

    json
