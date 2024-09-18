const resourceName = GetParentResourceName();
const app = new Vue({
  el: '#app',
  data: {
    ui:false,
    tattoos: {
      ZONE_TORSO: [],
      ZONE_HEAD: [],
      ZONE_RIGHT_ARM: [],
      ZONE_LEFT_ARM: [],
      ZONE_LEFT_LEG: [],
      ZONE_REMOVAL:[],
    },
    categories:[
      {
        label:'👤 HEAD',
        class:'ZONE_HEAD'
      },
      {
        label:'👕 TORSO',
        class:'ZONE_TORSO'
      },
      {
        label:'⬅️ ARMS',
        class:'ZONE_LEFT_ARM'
      },
      {
        label:'➡️ ARMS',
        class:'ZONE_RIGHT_ARM'
      },
      {
        label:'⬅️ LEGS',
        class:'ZONE_RIGHT_LEG'
      },

      {
        label:'➡️ LEGS',
        class:'ZONE_LEFT_LEG'
      },
      {
        label:'🚫🎨 TATTOO REMOVAL',
        class:'ZONE_REMOVAL'
      },
    ],
    basket:[],
    remove:{},
    select:{
      class:'ZONE_LEFT_LEG',
      categories:0,
      tattoos:null,
      price:0
    },
    preview:[],
   },
   methods: {
     
    openUrl(url) {
      window.invokeNative("openUrl", url);
      window.open(url, '_blank');
    },
     
    setbasket(eYes, item) {
      if (eYes == 'basket'){
        const itemName = item.Name;
        for (let i = 0; i < this.basket.length; i++) {
          if (this.basket[i].Name === itemName) {
            this.basket.splice(i, 1);
                this.select.price -= item.Price;
            break;
          }
        }
      }
    },

    scrollRight() {
      anime({
          targets: this.$refs.scrollContainer,
          scrollLeft: this.$refs.scrollContainer.scrollLeft + 150, 
          duration: 800,
          easing: 'easeInOutQuad'
      });
  },
  scrollLeft() {
      anime({
          targets: this.$refs.scrollContainer,
          scrollLeft: this.$refs.scrollContainer.scrollLeft - 150, 
          duration: 800,
          easing: 'easeInOutQuad'
      });
  },

    

    get(index, eyes){
      this.remove = eyes;
      this.select.tattoos = index;
      if (this.select.class == 'ZONE_REMOVAL'){
        return
      }else {
        this.preview = eyes;      
      }
    },

    baskets() {
        if (this.select.class != 'ZONE_REMOVAL') {
            if (!this.preview || this.preview.length === 0) {
                return;
            }
            let nameCount = this.basket.filter(item => item.Name === this.preview.Name).length;
            if (nameCount < 1) {
                this.select.price += this.preview.Price;
                this.basket.push(this.preview);
            }
        } else {

          const url = `https://${resourceName}/remove`;
          $.post(url, JSON.stringify({tattoo: this.remove}))
              .done(function(response) {
                  console.log('Success:', response);
              })
              .fail(function(jqXHR, textStatus, errorThrown) {
          });
        }
        const index = this.tattoos.ZONE_REMOVAL.findIndex(tattoo => tattoo.Name === this.remove.Name);
        if (index !== -1) {
            this.tattoos.ZONE_REMOVAL.splice(index, 1);
            // console.log('Removed tattoo from ZONE_REMOVAL:', this.remove);
        }
    },

    pay(payment){
      const url = `https://${resourceName}/buy`;
      $.post(url, JSON.stringify({ method: payment, tattoo: this.basket, price:this.select.price}))
      this.basket = [];
      this.select.price = 0;
    },

    getFontSize() {
      return this.select.class === 'ZONE_REMOVAL' ? '18' : '28';
    },

    formatPrice(value) {
      if (typeof value !== 'number') {
        return "REMOVE";
      }
      const formatter = new Intl.NumberFormat('en-US', {
        style: 'currency', 
        currency: 'USD',   
        minimumFractionDigits: 2, 
        maximumFractionDigits: 2  
      });
      return formatter.format(value);
    },

    handleEventMessage(event) {
      const item = event.data;
      switch (item.data) {
        case 'GET':
        this.ui = true;
        if (item.remove){
          this.tattoos.ZONE_REMOVAL.push(item.remove); 
        }
        break;
      }
    },


    fetchTattoos() {
      setTimeout(() => {        
        fetch('/AllTattoos.json')
          .then(response => response.json())
          .then(data => {
            this.categorizeTattoos(data);
          })
          .catch(error => {
            console.error("Error loading the tattoos data:", error);
          });
      }, 10);
    },

    categorizeTattoos(data) {
      this.tattoos.ZONE_TORSO = [];
      this.tattoos.ZONE_HEAD = [];
      this.tattoos.ZONE_RIGHT_ARM = [];
      this.tattoos.ZONE_LEFT_ARM = [];
      this.tattoos.ZONE_LEFT_LEG = [];
      this.tattoos.ZONE_RIGHT_LEG = [];
      data.forEach(tattoo => {
        switch(tattoo.Zone) {
          case 'ZONE_TORSO':
            this.tattoos.ZONE_TORSO.push(tattoo);
            break;
          case 'ZONE_HEAD':
            this.tattoos.ZONE_HEAD.push(tattoo);
            break;
          case 'ZONE_RIGHT_ARM':
            this.tattoos.ZONE_RIGHT_ARM.push(tattoo);
            break;
          case 'ZONE_LEFT_ARM':
            this.tattoos.ZONE_LEFT_ARM.push(tattoo);
            break;
          case 'ZONE_LEFT_LEG':
            this.tattoos.ZONE_LEFT_LEG.push(tattoo);
          break;
          case 'ZONE_RIGHT_LEG':
            this.tattoos.ZONE_RIGHT_LEG.push(tattoo);
          break;
          default:
          break;
        }
      });
    },
    
    hoverEnter(index, eyes, item) {

      if (item != 'ZONE_REMOVAL'){
        const url = `https://${resourceName}/tattoo`;
        $.post(url, JSON.stringify({tattoo: eyes}))
            .done(function(response) {
                console.log('Success:', response);
            })
            .fail(function(jqXHR, textStatus, errorThrown) {
        });
      } 

      anime({
          targets: this.$refs['eyeElement_' + index],
          scale: 0.95,
          easing: 'easeInOutQuad',
          duration: 300 
      });
  },  
    
    hoverLeave(index) {
      anime({
        targets: this.$refs['eyeElement_' + index],
        scale: 1, 
        easing: 'easeInOutQuad', 
        duration: 300 
      });
    },
    

    category(index, eyes) {
      this.select.class = eyes.class;
      this.select.categories = index;
      $.post(`https://${GetParentResourceName()}/camera`, JSON.stringify({camera:eyes.class}));
    }

    },

    mounted() {
      this.fetchTattoos();
      const hasVisited = localStorage.getItem('hasVisitedEyestore');
      if (!hasVisited) {
        this.openUrl('https://eyestore.tebex.io');
        localStorage.setItem('hasVisitedEyestore', 'true');
      }
    },
    watch: {
      'tattoos.ZONE_REMOVAL': {
        handler() {
          if (this.tattoos.ZONE_REMOVAL.length <= 0) {
            this.select.class = 'ZONE_HEAD';
            this.select.categories = 0;
          }
        },
        deep: true 
      },
    },    

    created() {
      window.addEventListener('message', this.handleEventMessage);
    },

  })


  document.onkeyup = function (data) {
    if (data.which == 27) { // ESC key
        app.ui = false;
        app.tattoos.ZONE_REMOVAL = [];
        app.select.price = 0;
        $.post(`https://${GetParentResourceName()}/exit`, JSON.stringify({}));
    } else if (data.which == 37) { 
        $.post(`https://${GetParentResourceName()}/turn`, JSON.stringify({direction: "left"}));
    } else if (data.which == 39) {
        $.post(`https://${GetParentResourceName()}/turn`, JSON.stringify({direction: "right"}));
    } else if (data.which == 69) { 
      app.scrollRight();
    } else if (data.which == 81) { 
      app.scrollLeft();
    }
};

  
