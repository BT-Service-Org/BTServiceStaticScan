import { LightningElement,api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript } from 'lightning/platformResourceLoader';
import Gauge from '@salesforce/resourceUrl/GDC_MS_Gauge';

import getCount from '@salesforce/apex/GDC_MS_ScoreCalculation.getCount';

export default class GdcmsCalculateScore extends LightningElement {
  @api recordId;

  chart;
  boolShowSpinner = true;
  
  count = 0;
  percentage = 0;
  total = 0;

  connectedCallback() {
    this.getData();
  }

  getData(){
    getCount({strId:this.recordId})
    .then(result => {
      
      this.count = result.intScore;
      this.total = result.intApplicable;
      this.percentage = result.intPercentage;
      this.boolShowSpinner = false;

      loadScript(this, Gauge).then(() =>{this.initializeGauge()})
    })
    .catch(error => {
      this.boolShowSpinner = false;
      if (error && error.body && error.body.message) {
        this.showToast('Error', error.body.message,'error');
      }
    });
  }

  initializeGauge() {
      var config = {
        type: 'gauge',
        data: {
          labels: ['< 61%', '< 80%', '>= 80%'],
          datasets: [{
            data: [
                61,
                80,
                100
              ],
            value: this.percentage,
            backgroundColor: ['red', 'orange', 'green'],
            borderColor:['red', 'orange', 'green'],
            borderWidth: 1
          }],
          
        },
        options: {
          responsive: true,
          animation:{
            duration:10,
            delay:0
          },
          tooltips: {
            enabled: true,
            displayColors:false,
          },
          title: {
            display: true,
            text: 'Percentage',
            family:"'Arial'",
            weight:650,
            size:14
          },
          legend: {
            display: true,
            position:"right",
            labels : {
              boxWidth:20,
              fontSize:12,
              fontColor: '#000',
              fontStyle:'bold',
                generateLabels: function(chart) {
                    var data = chart.data;
                    if (data.labels.length && data.datasets.length) {
                      return data.labels.map(function(label, i) {
                        var meta = chart.getDatasetMeta(0);
                        var ds = data.datasets[0];
                        return {
                          text: label,
                          fillStyle: ds.backgroundColor[i],
                          strokeStyle: 'black',
                          lineWidth: '1',
                        };
                      });
                    }
                    return [];
                  }
            }
            
          },
          cutoutPercentage: 85,
          layout: {
            padding: {
              bottom: 20
            }
          },
          needle: {
            radiusPercentage: 1.8,
            widthPercentage: 1.5,
            lengthPercentage: 80,
            color: 'rgba(0, 0, 0, 1)'
          },
          valueLabel: {
            display:true,
            formatter: function(value) {
              return value + '%';
            },
            backgroundColor: 'rgba(255, 255, 255, 1)',
            color: 'rgba(0, 0, 0, 1)',
            borderRadius: 0,
            padding: {
              top: 0,
              right: 0,
              bottom: 0,
              left: 0
            },
            bottomMarginPercentage: -6
          },
          plugins: {
            datalabels: {
              display: false,
              formatter: function (value, context) {
                return '< ' + Math.round(value);
              },
              color: function (context) {
                return context.dataset.backgroundColor;
              },
              backgroundColor: 'rgba(0, 0, 0, 1.0)',
              borderWidth: 0,
              borderRadius: 2,
              font: {
                weight: 'bold'
              }
            }
          }
        }
      };

      try{
        const canvas2 = document.createElement('canvas'); 
        const ctx = this.template.querySelector('.chart').getContext('2d');
        this.chart= new window.Chart(ctx, config);
      } catch(error) {
        this.showToast('Error', error,'error');
    }
  }

  showToast(title,message, type) {
    const event = new ShowToastEvent({
        title: title,
        variant: type,
        message: message,
    });
    this.dispatchEvent(event);
  }
}