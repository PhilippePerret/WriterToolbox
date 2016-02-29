if('undefined' == typeof FILM_ID){
  FILM_ID     = null;
  FILM_DUREE  = null ;
}
window.Film = {
  id    : null, // fixé par le programme
  duree : null, // fixé par le programme

  init_values:function(){
    this.id     = FILM_ID ;
    this.duree  = FILM_DUREE ;
  }
}
