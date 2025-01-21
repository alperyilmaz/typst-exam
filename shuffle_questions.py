import re
import random
import sys
import csv
import os

def read_csv_table(csv_path):
    try:
        with open(csv_path, 'r') as f:
            reader = csv.reader(f)
            table_data = [tuple(row) for row in reader]
            return table_data
    except FileNotFoundError:
        print(f"Warning: CSV file '{csv_path}' not found.", file=sys.stderr)
        return None
    except IOError:
        print(f"Warning: Unable to read CSV file '{csv_path}'.", file=sys.stderr)
        return None

def read_code_file(file_path):
    try:
        with open(file_path, 'r') as f:
            return f.read().strip()
    except FileNotFoundError:
        print(f"Warning: Code file '{file_path}' not found.", file=sys.stderr)
        return None
    except IOError:
        print(f"Warning: Unable to read code file '{file_path}'.", file=sys.stderr)
        return None

def format_table_data(table_data):
    if not table_data:
        return ""
    
    formatted_rows = []
    for row in table_data:
        formatted_row = ', '.join(f'"{cell}"' for cell in row)
        formatted_rows.append(f'        ({formatted_row})')
    
    return '      table: (\n' + ',\n'.join(formatted_rows) + '\n      ),'

def format_code_data(code_content, language):
    if not code_content:
        return ""
    # Escape newlines and quotes in the code content
    escaped_content = code_content.replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n')
    return f'      code: (\n        content: "{escaped_content}",\n        lang: "{language}"\n      ),'


def escape_quotes(text):
    # no need for escaping  parenthesis  .replace('(','\(').replace(')','\)')
    # might not need escaping newline  replace('\\n','\\\\n')
    return text.replace('"', '\\"').replace('\\t','\\\\t').replace('\\n','\\\\n').replace('\\r','\\\\r').replace('*','\*')

def format_tuple_with_double_quotes(items):
    formatted_items = [f'"{escape_quotes(item)}"' for item in items]
    return f'({", ".join(formatted_items)})'

def remove_asterisk_end(item):
    item = re.sub(r'\*$', '', item)
    return re.sub(r'\+$', '', item)

def format_tuple_with_double_quotes_noasterisk(items):
    formatted_items = [f'"{escape_quotes(remove_asterisk_end(item))}"' for item in items]
    return f'({", ".join(formatted_items)})'

def shuffle_questions_and_choices(content, myseed, output_base):
    # Create output filenames
    questions_file = f"{output_base}-{myseed}.typ"
    answers_file = f"{output_base}-{myseed}-answers.typ"

    # Split the content into individual questions
    questions = re.split(r'\n\s*\n', content.strip())

    # Shuffle the order of questions
    random.seed(myseed)
    random.shuffle(questions)

    # Open both files for writing
    with open(questions_file, 'w') as qf, open(answers_file, 'w') as af:
        # Write header to both files
        for f in [qf, af]:
            f.write("#let exam_content(exam_func) = {\n exam_func(\n questions: (\n")

        for question in questions:
            lines = question.strip().split('\n')

            prompt = escape_quotes(lines[0].replace("Question: ", "").strip())
            if prompt.startswith("#"):
                continue

            current_line_idx = 1
            image_info = None
            table_info = None
            code_info = None
            while current_line_idx < len(lines):
                current_line = lines[current_line_idx].strip()

                if current_line.startswith("image:"):
                    image_parts = current_line.replace("image:", "").strip().split(",")
                    image_path = image_parts[0].strip()
                    image_width = int(image_parts[1].strip()) if len(image_parts) > 1 else 95
                    image_info = f'      image: (path: "{image_path}", width: {image_width}%),'
                    current_line_idx += 1
                elif current_line.startswith("table:"):
                    csv_path = current_line.replace("table:", "").strip()
                    table_data = read_csv_table(csv_path)
                    if table_data:
                        table_info = format_table_data(table_data)
                    current_line_idx += 1
                elif current_line.startswith("code:"):
                    code_parts = current_line.replace("code:", "").strip().split(",")
                    code_path = code_parts[0].strip()
                    code_lang = code_parts[1].strip() if len(code_parts) > 1 else "text"
                    code_content = read_code_file(code_path)
                    if code_content:
                        code_info = format_code_data(code_content, code_lang)
                    current_line_idx += 1
                else:
                    break

            # Get the options and track correct answer
            options = []
            options_with_asterisk = []
            for option in lines[current_line_idx:]:
                # be careful about paranthesis in the option text
                try:
                    #option_text = option.split(') ',1)[1].strip()
                    option_text = re.sub(r'^[A-Fa-f][\)\.]\s*', '', option).strip()
                    options.append(option_text)
                except(IndexError, AttributeError) as e:
                    print(f"Error at line index: {current_line_idx}")
                    print(f"Error details: {str(e)}")
                    print(f"Problematic input: {option}")
                    
            # Create a shuffled version for the questions file
            shuffled_options = options.copy()
            random.shuffle(shuffled_options)

            # Write question without answers (shuffled, no asterisks)
            qf.write(f'    (\n')
            qf.write(f'      prompt: "{prompt}",\n')
            if image_info:
                qf.write(f'{image_info}\n')
            if table_info:
                qf.write(f'{table_info}\n')
            if code_info:
                qf.write(f'{code_info}\n')
            qf.write(f'      options: {format_tuple_with_double_quotes_noasterisk(shuffled_options)},\n')
            qf.write(f'    ),\n')
            
            # Write question with answers (shuffled, with asterisks preserved)
            af.write(f'    (\n')
            af.write(f'      prompt: "{prompt}",\n')
            if image_info:
                af.write(f'{image_info}\n')
            if table_info:
                af.write(f'{table_info}\n')
            if code_info:
                af.write(f'{code_info}\n')
            af.write(f'      options: {format_tuple_with_double_quotes(shuffled_options)},\n')
            af.write(f'    ),\n')
        
        # Write footer to both files
        for f in [qf, af]:
            f.write(" )\n )\n}")

def main():
    if len(sys.argv) != 3:
        print("Usage: python script.py <input_file> <seed>")
        sys.exit(1)

    input_file = sys.argv[1]
    seed = int(sys.argv[2])
    
    # Create output base name from input file
    output_base = os.path.splitext(input_file)[0]
    
    try:
        with open(input_file, 'r') as f:
            content = f.read()
    except FileNotFoundError:
        print(f"Error: File '{input_file}' not found.")
        sys.exit(1)
    except IOError:
        print(f"Error: Unable to read file '{input_file}'.")
        sys.exit(1)

    shuffle_questions_and_choices(content, seed, output_base)

if __name__ == "__main__":
    main()

