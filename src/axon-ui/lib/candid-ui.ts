import { IDL, inputBox, InputBox, RecordForm, TupleForm, VariantForm, OptionForm, InputForm, VecForm as VecFormType } from "@dfinity/candid";

function hexToBytes(hex) {
    for (var bytes = [], c = 0; c < hex.length; c += 2)
        bytes.push(parseInt(hex.substr(c, 2), 16));
    return bytes;
}

const FormConfig = { render: renderInput };
const recordForm = (fields, config) => {
    return new RecordForm(fields, Object.assign(Object.assign({}, FormConfig), config));
};
const tupleForm = (components, config) => {
    return new TupleForm(components, Object.assign(Object.assign({}, FormConfig), config));
};
const variantForm = (fields, config) => {
    return new VariantForm(fields, Object.assign(Object.assign({}, FormConfig), config));
};
const optForm = (ty, config) => {
    return new OptionForm(ty, Object.assign(Object.assign({}, FormConfig), config));
};

class VecForm extends InputForm {
    constructor(ui) {
        super(ui);
        this.ui = ui;
    }
    generateForm() {
        const input = this.ui.render(IDL.Text);
        input.label = "(HEX)";
        this.form = [input];
    }
    parse(config) {
        const value = this.form.map(input => {
            console.log(hexToBytes(input.value || ""));
            return hexToBytes(input.value || "");
        });

        return value[0];
    }
}
const vecForm = (config) => {
    return new VecForm(Object.assign(Object.assign({}, FormConfig), config));
};

export class CustonRender extends IDL.Visitor<null, InputBox> {
    visitType(t, d) {
        const input = document.createElement('input');
        input.classList.add('argument');
        input.placeholder = t.display();
        return inputBox(t, { input });
    }
    visitNull(t, d) {
        return inputBox(t, {});
    }
    visitRecord(t, fields, d) {
        let config = {};
        if (fields.length > 1) {
            const container = document.createElement('div');
            container.classList.add('popup-form');
            config = { container };
        }
        const form = recordForm(fields, config);
        return inputBox(t, { form });
    }
    visitTuple(t, components, d) {
        let config = {};
        if (components.length > 1) {
            const container = document.createElement('div');
            container.classList.add('popup-form');
            config = { container };
        }
        const form = tupleForm(components, config);
        return inputBox(t, { form });
    }
    visitVariant(t, fields, d) {
        const select = document.createElement('select');
        for (const [key, type] of fields) {
            const option = new Option(key);
            select.add(option);
        }
        select.selectedIndex = -1;
        select.classList.add('open');
        const config = { open: select, event: 'change' };
        const form = variantForm(fields, config);
        return inputBox(t, { form });
    }
    visitOpt(t, ty, d) {
        const checkbox = document.createElement('input');
        checkbox.type = 'checkbox';
        checkbox.classList.add('open');
        const form = optForm(ty, { open: checkbox, event: 'change' });
        return inputBox(t, { form });
    }

    visitVec(t, ty, d) {
        const input = document.createElement('input');
        input.type = 'text';
        input.style.width = '8rem';
        input.placeholder = 'hex';
        const form = vecForm({ input, event: 'change' });
        return inputBox(t, { form });
    }

    visitRec(t, ty, d) {
        return renderInput(ty);
    }
}

/**
 *
 * @param t an IDL type
 * @returns an input for that type
 */
export function renderInput(t) {
    return t.accept(new CustonRender(), null);
}