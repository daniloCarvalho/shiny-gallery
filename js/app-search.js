---
layout: none
---

// TODO: generate the json during import time into search.json and then
// load it async from the typeahead.source function (the process argument
// is a callback you can use async)
window.Apps = [
{% for post in site.posts %}
{
  title: '{{ post.title }}',
  tags: '{{ post.tags | join: ' ' }}',
  url: '{{ site.baseurl }}{{ post.url }}',
  thumbnail: '{{ site.baseurl }}/images/thumbnails/{{ post.thumbnail }}',
  content: '{{ post.content | strip_newlines }}'
},  
{% endfor %}
null
];


function initializeAppSearch(searchElement) {
  $(searchElement).typeahead({
    
    items: 5,
    minLength: 2,
    
    // define data source from app array defined above
    source: function(query, process) {
      
      result = []
      for (i=0;i<window.Apps.length;i++) {
        
        // null app is a sentinel for the end of the array
        var app = window.Apps[i];
        if (!app)
          break;
      
        var val = new String(app.url);
        val.data = app;
        result.push(val);
      }
      return result;
    },
    
    // custom search function
    matcher: function(item) {
      var app = item.data;
      return app.title.toLowerCase().search(this.query) != -1 ||
             app.tags.toLowerCase().search(this.query) != -1 ||
             app.content.toLowerCase().search(this.query) != -1
    },
    
    // custom sorting function
    sorter: function(items) {
      return items; // TODO: give preference to title and tag matches
    },
    
    // custom rendering function
    highlighter: function(item) {
      var app = item.data;
      var html = ''
         + "<div class='app-typeahead-wrapper'>"
         + "<img class='app-typeahead-thumbnail img-polaroid' src='" + app.thumbnail + "' />"
         + "<div class='app-typeahead-text'>"
         + "<strong>" + app.title + "</strong><br/>"
         + "<small>" + app.content + "</small>"
         + "</div>"
         + "</div>";
      return html;
    },
    
    // accept redirects to the item
    updater: function(item) {
      window.location.href = item;
    }
  });
    
}