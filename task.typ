// -------------------- Utils --------------------

// Returns the first argument that is not equal to `none`.
// Returns `none` if all arguments are equal to `none`.
#let ifnone(..args) = {
    for arg in args.pos() {
        if arg != none {
            arg
            break
        }
    }
    
    none
}

// -------------------- Doc --------------------

#let doc_data = state("doc_data", (:))

#let conf(
    title: none,
    short_title: none,
    show_score_table: true,
    show_ans_table: true,
    reset_tour_page_counter: true,
    body
) = {
    // Update variables
    doc_data.update((
        title: title,
        short_title: ifnone(short_title, title),
        show_score_table: show_score_table,
        show_ans_table: show_ans_table,
        reset_tour_page_counter: reset_tour_page_counter,
    ))

    // Body
    body
}

// -------------------- Tour --------------------

#let tour_counter = counter("tour_counter")
#let tour_tasks = state("tour_tasks", ())

#let this_tour_end() = {
    query(selector(label("tour_end")).after(here())).first().location()
}

#let tour_score_table() = {
    let tasks = tour_tasks.at(this_tour_end())
    let total_score = tasks.map(task => task.score).sum(default: 0)
    let score_box = box(width: 0.7cm, height: 0.7cm)

    let nums_row = range(1, tasks.len() + 1).map(id => str(id))
    let max_scores_row = tasks.map(task => $#task.score$)
    let scores_row = tasks.map(task => score_box)

    table(
        columns: tasks.len() + 2,
        [*Задача:*],     ..nums_row,       $sum$,
        [*Макс. балл:*], ..max_scores_row, $#total_score$,
        [*Балл:*],       ..scores_row,     score_box,
    )
}

#let tour_ans_table() = {
    let tasks = tour_tasks.at(this_tour_end())
    let row = tasks
        .enumerate()
        .map(((id, task)) => (
            str(id + 1),
            task.name,
            par(justify: true, task.ans)
        )).flatten()

    table(
        columns: (auto, auto, 1fr),
        [*№*], [*Задача*], [*Ответ*],
        ..row
    )
}

#let tour(
    title: none,
    show_score_table: none,
    show_ans_table: none,
    body
) = {
    // Update variables
    tour_tasks.update(())
    tour_counter.step()

    context {
        if doc_data.get().reset_tour_page_counter {
            counter(page).update(1)
        }
    }

    // Page setup
    // NOTE Works on the answers page only. Seems to be related to https://github.com/typst/typst/issues/2987
    set page(
        header: align(center, context {
            let footer = ()
            
            if doc_data.get().short_title != none {
                footer.push(doc_data.get().short_title)
            }

            footer.push([Тур #tour_counter.display()])

            if title != none {
                footer.push(["#title"])
            }

            footer.join(". ")
            line(length: 100%, stroke: 0.5pt)
        }),
        footer: align(center)[Лист #counter(page).display()],
    )

    // Title
    pagebreak(weak: true)
    if title != none {
        align(center, text(18pt, weight: "bold", context {
            if doc_data.get().title != none {
                doc_data.get().title
                linebreak()
            }

            [Тур ]
            tour_counter.display()

            if title != none {
                linebreak()
                ["#title"]
            }
        }))
    }
    
    // Scores table
    context {
        if ifnone(show_score_table, doc_data.get().show_score_table, true) {
            align(center, tour_score_table())
        }
    }

    // Body
    body

    // Answers table
    context {
        if ifnone(show_ans_table, doc_data.get().show_ans_table, true) {
            pagebreak()
            align(center, {
                text(18pt, weight: "bold")[Ответы]

                tour_ans_table()
            })
        }
    }

    [#none <tour_end>]
}

// -------------------- Tasks --------------------

#let score_as_word(score) = {
    let orig_score = score

    if score >= 20 {
        score = calc.rem(score, 10)
    }

    let word = if score == 0 [баллов]
        else if score == 1 [балл]
        else if score <= 4 [балла]
        else if score <= 19 [баллов]
        else { panic("unreachable") }

    [#orig_score #word]
}

#let task(score: 1, with_proof: false, name, cond, ans) = box(width: 1fr, {
    // Update variables
    tour_tasks.update(t => {
        t.push((
            name: name,
            score: score,
            ans: ans,
        ))
        t
    })

    // Title
    v(0.5cm)
    align(center, text(14pt, weight: "bold", context [
        Задача #tour_tasks.get().len(). #name (#score_as_word(score))
    ]))

    // Condition
    cond

    // Answer/ proof field
    if with_proof [
        *\ Решение:*

        #box(width: 1fr, height: 5cm)
    ] else [
        *\ \ Ответ: * #box(width: 5cm, stroke: (bottom: 0.5pt))
    ]
})
