import { LightningElement, wire } from 'lwc';
import dataToObject from '@salesforce/apex/ucl_ConexionData.dataToObject';
export default class Invoke_JSON extends LightningElement {

    handleClick(){
        dataToObject({})
        window.alert("La lista ha sido cargada");
        
        
    }
}