function fn() {
    var token = karate.get('token');
    if (token) {
      return { 
          Authorization: 'Bearer ' + token,
      };
    } else {
      return {
      };
    }
  }