import argparse
import json
import os

class AppTool:
    #actions
    def action_decode(self, input_file, output_file):
        print("Decoding from: " + input_file)
        self.action_decode_impl(input_file, output_file)

    def action_get_resources_list(self, input_file):
        #TODO
        print("Resources from: " + input_file)

    def action_sn_text(self, input_file):
        #TODO
        #print("SN text from: " + input_file)
        self.action_sn_text_impl(input_file)

    def action_help(self):
        print("Help topics: ")

    #actions impl
    def action_decode_impl(self, input_file, output_file):
        try:
            with open(input_file, 'r') as file:
                data = file.read()

            #print("File: ") #TO DEBUG
            #print(data)
            decoded_data = self.remove_escape_char(data)
            print("Decoded data: ")
            print(decoded_data)
            with open(output_file, 'w') as output_file:
                output_file.write(str(decoded_data))
        except FileNotFoundError:
            print(f"Error: File: '{ìnput_file}' not found.")
        except json.JSONDecodeError:
            print(f"Error: unable to parse JSON data from: '{ìnput_file}'.")

    #actions impl sn text
    def action_sn_text_impl(self, input_file):
        try:
            with open(input_file, 'r') as file:
                data = file.read()

            #print("File: ") #TO DEBUG
            #print(data)
            #print("Variables data: ")
            data_json = json.loads(data)
            texto1 = data_json["variables"]["resources"]["value"]["lambdaFunctions"][0]["resourceName"]
            #os.environ['TEXT01'] = 'str(texto1)'
            texto1_completo = f"""TEXTO1='Nome da Lambda: {texto1}
Numero de requisicoes
Teste'"""
            texto1_completo_escaped
            print(texto1_completo)
            print(f"export {texto1_completo}")
            
        except FileNotFoundError:
            print(f"Error: File: '{ìnput_file}' not found.")
        except json.JSONDecodeError:
            print(f"Error: unable to parse JSON data from: '{ìnput_file}'.")
    
    def remove_escape_char(self, data):
        if isinstance(data, dict):
            #print("Dict: ") #TO DEBUG
            return {self.remove_escape_char(key): self.remove_escape_char(value) for key, value in data.items()}
        elif isinstance(data, list):
            #print("List: ") #TO DEBUG
            return [self.remove_escape_char(item) for item in data]
        elif isinstance(data, str):
            #print("Replace: ") #TO DEBUG
            return data.replace('"{\\"', '{"').replace('\\', '').replace(':\'{', ':{').replace('}\',', '},').replace('"{', "{").replace('}"', "}") ## removing string limitation of azuredevops api to full json format
        else:
            return data

if __name__ == "__main__":
    app = AppTool()
    parser = argparse.ArgumentParser(description="PlataformTool")

    parser.add_argument("action",
                        choices=["run-decode", "run-get-resources-list", "run-sn-text"],
                        help="Select a action to run")

    parser.add_argument("--input-file", "-i", help="Input file for decoding")
    parser.add_argument("--output-file", "-o", help="Output file for decoding")

    args = parser.parse_args()

    if args.action == "run-decode":
        app.action_decode(args.input_file, args.output_file)
    
    elif args.action == "run-get-resources-list":
        app.action_get_resources_list(args.input_file)
    
    elif args.action == "run-sn-text":
        app.action_sn_text(args.input_file)

    else:
        print("Invalid option.")