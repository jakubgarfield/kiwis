var galleryLinks = document.getElementsByClassName("gallery-link");
for (var i = 0; i < galleryLinks.length; i++) {
  galleryLinks[i].onclick = function (event) {
    event = event || window.event;
    var target = event.target || event.srcElement;
    var link = target.src ? target.parentNode : target;
    var options = {index: link, event: event};
    blueimp.Gallery(galleryLinks, options);
  };
}
