var container = document.getElementById("gallery-container");
if (container) {
  imagesLoaded(container, function() {
    msnry = new Masonry(container);
  });

  container.onclick = function (event) {
    event = event || window.event;
    var target = event.target || event.srcElement,
        link = target.src ? target.parentNode : target,
        options = {index: link, event: event},
        links = this.getElementsByTagName('a');
    blueimp.Gallery(links, options);
  };
}
