# Plan & Design
## Desine Requirements
### What features does my app need ?
### What data will I work with ?
### What user interactions are required ?
## Design Data Structure
### Sketch out the data models
### Define what operation I need

# Build the Model
The model is independant and contains our core business logic 

```js
class TodoModel
{
    constructor()
    {
        this.todos = [];
    }
    addTodo(text) { /*...*/ };
    remoteTodo(id){ /*...*/ };
    getTodos()  { /*....*/};
}
```
If I start directly with model, I'll get the benefit of getting my first hands on the project avoiding annoying dependencies on UI. Also it's easier to test in console. We would need to define the data structured and operations encapsulating in classes. 
Finally starting with model I can start a good modularization API.

# Build the view 
# Build the presenter
# Wire everything together


The core Rule I'll try to respect is:
1. Core(model) - Business logic, no dependencies
2. Shell(View) - UI presentation, minimal logic
3. Glue(Presenter) -Connects everything together

