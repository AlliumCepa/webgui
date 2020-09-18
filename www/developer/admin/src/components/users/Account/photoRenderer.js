import React from 'react';
import { Inplace, InplaceDisplay, InplaceContent } from 'primereact/inplace';
import { InputText } from 'primereact/inputtext';

export default ({user, updateField}) => {
   return (
      <div className="p-grid">          
         <div className="p-col-1 text-right font-weight-bold">Photo:</div>         
         <Inplace closable className="p-col-11">
            <InplaceDisplay>
               {user.photo || 'Click to Edit'}
            </InplaceDisplay>
            <InplaceContent>
               <InputText value={user.photo} onChange={(e) => updateField('photo', e.target.value)} autoFocus />
            </InplaceContent>
         </Inplace>    
      </div>
   );
};