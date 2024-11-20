# Multiple choice exam sheet wirh typst

Please prepare your questions in markdown format in the following format:

```
Question: text for question
A) option1
B) option2
C) option3
D) option4+
E) option5
```

The correct answers are indicated with `+` sign. You can print PDF version with answers if you like. 

If you have a table or image, you can include them right after the question as shown below. The number after the image filename determines the size. Tables are accepted in csv format.

```
Question: text for question
image: filename.png,80
A) option1
B) option2
C) option3
D) option4+
E) option5
```
OR
```
Question: text for question
table: filename.csv
A) option1
B) option2
C) option3
D) option4+
E) option5
```

In order to shuffle the questions, run the Python script. Please provide a seed number for random shuffling. This will help you generating the same shuffle with same seed number.

```python
python shuffle_questions.py sample_questions.md 1
```

Then you can compile the questions with the exam template. `booklet` info is printed at the bottom of the exam sheet. 

```
typst c main.typ --input booklet=A --input questions=sample_questions-1.typ test.pdf
```
