#import "bubble.typ": sheet

#let exam(
  questions: (), 
  custom_header: none,
  booklet_name: none
) = {
  set document(author: "Exam Creator")
  set page(
    numbering: "1 / 1",
    number-align: center,
    margin: (left: 0.5in, right: 0.5in, top: 0.5in, bottom: 0.5in),
  )

  set text(font: "New Computer Modern", size: 10.7pt)

  // Function to convert number to uppercase letter
  let to-letter(num) = {
    if num >= 1 and num <= 26 {
      ("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
       "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z").at(num - 1)
    } else {
      "?"
    }
  }

  // Function to layout options based on their length
  let layout-options(options) = {
    let max_length = options.fold(0, (acc, opt) => calc.max(acc, opt.len()))
    if max_length <= 4 {
      grid(
        columns: (1fr,) * calc.min(options.len(), 5),
        row-gutter: 0.5em,
        ..options.enumerate().map(((i, opt)) => [#to-letter(i + 1)) #opt])
      )
    } else if max_length <= 20 {
      grid(
        columns: (1fr, 1fr),
        row-gutter: 0.5em,
        ..options.enumerate().map(((i, opt)) => [#to-letter(i + 1)) #opt])
      )
    } else {
      for (i, option) in options.enumerate() {
        [#to-letter(i + 1)) #eval(option,mode: "markup")]
        linebreak()
      }
    }
  }

  // Function to create a table with a specific font size
  let create_table(data, font_size) = {
    context {
      set text(size: font_size)
      table(
        columns: (auto,) * data.at(0).len(),
        inset: 5pt,
        align: center,
        ..data.flatten()
      )
    }
  }

  // Function to render a question with potential image or table
  let render-question(question, index) = {
    block(width: 100%, breakable: false)[
      *#(index + 1). #eval(question.at("prompt"),mode:"markup")*
      
      #if "image" in question {
        //block(align(center)[
        box(width: 100%, align(center)[
          #image(question.at("image").path, width: question.at("image").width)
        ])
      }
      
      #if "table" in question {
        let table-data = question.at("table")
        let table-font-size = 9pt
        //block(align(center)[
        box(width: 100%, align(center)[  
          #create_table(table-data, table-font-size)
        ])
      }

      #if "code" in question {
        let code-data = question.at("code")
        block(width: 100%, inset: (x: 2em))[
          #raw(code-data.content, lang: code-data.lang)
        ]
      }
      #v(0.5em)
      #layout-options(question.at("options"))
      #v(1em)
    ]
  }


  // Function to insert a single column break at a specified position
  let insert_single_colbreak(blocks, position) = {
    blocks.enumerate().map(((i, block)) => {
      if i == position {
        (block, colbreak())
      } else {
        block
      }
    }).flatten()
  }

  [
    // Output the header
    #custom_header()
    
    #v(1em)

    // Questions with a single column break
    #let break_after_question = 34
    #let question-blocks = questions.enumerate().map(((index, question)) => {
      render-question(question, index)
    })
    #let questions_with_break = insert_single_colbreak(question-blocks, break_after_question - 1)
     
    // two columns with no line
    #columns(2, gutter: 1em)[
      #questions_with_break.join()
    ]
  
    // Add the answer sheet at the bottom of the last page
    #place(bottom+center, dy: -1em)[
        #sheet(num-choices: 5, total-questions: 16, questions-per-col: 4)
    ]

    // Add booklet name (using the direct parameter)
    #place(bottom + right, dy: 0em, dx: -0.7em)[
      #text(weight: "bold", size: 13pt, booklet_name)
    ]
  ]
}
