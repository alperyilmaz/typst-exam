#let header-top(
  course_code: none,
  course_name: none,
  group: none,
  instructor: "Assoc.Prof.Dr.Alper YILMAZ",
  exam_duration: none,
  exam_date: none,
  exam_type: none,
  department: none,
  term: none,
  semester: none,
  booklet_name: none  // Added this parameter
) = {
  // Set Turkish language for proper hyphenation and typography
  set text(lang: "tr",size: 0.8em)

   table(
    columns: (auto,1fr,1fr,1fr,1fr,45pt),
    rows:(auto,20pt,20pt,auto),
    align: center,
    stroke: 0.5pt,
    inset: 5pt,

    // Left column with logo and text
    table.cell(rowspan: 4)[
      #align(center)[
        #image("university-logo.png", width: 50pt)

        #text(weight: "bold")[
          UNIVERSITY OF X FACULTY OF SCIENCE AND LETTERS
        ]
        #linebreak()
        #text(weight: "bold")[
          DEPARTMENT OF #department 
        ]
        #linebreak()
        #text(weight: "bold")[
          #term ACADEMIC YEAR #semester SEMESTER
        ]
        #linebreak()
        #text(weight: "bold")[
          #exam_type EXAM QUESTIONS AND SOLUTIONS SHEET
        ]
      ]
    ],

    // Right column with grade table
    table.cell(colspan:5)[NOTE CHART],
    [],[], [],[],table.cell(rowspan: 2)[TOTAL]
  )
  
  v(-0.9em)
  
  table(
    columns: (105pt,1fr,85pt,85pt),
    rows:(auto,20pt,auto,auto,auto),
    align: center,
    stroke: 0.5pt,
    inset: 5pt,
    
    [#text(weight: "bold")[STUDENT NAME LASTNAME]],[],[#text(weight: "bold")[SIGNATURE]],[],
    [#text(weight: "bold")[NUMBER]],[],[#text(weight: "bold")[DEPARTMENT]],[],
    [#text(weight: "bold")[COURSE]],[#course_code #course_name #group],[#text(weight: "bold")[DATE]],[#exam_date],
    [#text(weight: "bold")[LECTURER]],[#instructor],[#text(weight: "bold")[DURATION]],[#exam_duration],

    // Right column with grade table
    table.cell(colspan:4)[*WARNING*: According to law, students caught in act of cheating are suspended.]
  )
}
