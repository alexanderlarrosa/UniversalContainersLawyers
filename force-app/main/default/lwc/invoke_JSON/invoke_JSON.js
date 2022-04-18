import { LightningElement, wire, track } from 'lwc';
import dataToObject from '@salesforce/apex/ucl_ConexionData.dataToObject';
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';
export default class Invoke_JSON extends LightningElement {

    @track conexionStatus;
    @track error;

    handleLoad(){
        dataToObject()
            .then(result => {
                this.conexionStatus = result;
                alert('Datos cargados con exito');
            })
            .catch(error => {
                this.error = error;
                console.log(error);
                alert('Error al cargar los datos');
            });
        
        
    }
}