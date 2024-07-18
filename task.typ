// -------------------- Utils --------------------

/// Returns the first argument that is not equal to `none`.
/// Returns `none` if all arguments are equal to `none`.
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

/// Global document context. Holds both configuration and internal data.
/// Is initialized by `conf` function.
#let ctx_default = state("ctx", (
    /// Template configuration. Generated from `conf` function arguments and
    /// defaults.
    /// @type dict
    conf: (
        /// Full document title.
        /// @type content | none
        title: none,

        /// Short document title.
        /// @type content | none
        short_title: none,

        /// Show score table for each tour. Can be overwritten for each tour.
        /// @type bool
        show_tour_score_table: true,

        /// Show score table for all document.
        /// @type bool
        show_global_score_table: true,

        /// Show score table for each tour. Can be overwritten for each tour.
        /// @type bool
        show_ans_table: true,

        /// Show ans table for all document.
        /// @type bool
        show_global_ans_table: true,

        /// Reset page counter for each tour.
        /// @type bool
        reset_tour_page_counter: true,
    ),

    /// Internal data.
    /// @type dict
    data: (
        /// Array of tours.
        /// @type array<tour>
        tours: (),
    ),
))

#let ctx = state("ctx", none)

/// Initializes document context.
/// See docs for `ctx_default.conf` for info about arguments.
#let conf(
    ..args,
    body
) = {
    ctx.update({
        let ctx = ctx_default
        for (key, value) in args.named() {
            ctx.conf[key] = value
        }
        ctx
    })

    // Body
    body
}

// -------------------- Tour --------------------

/// Tour data. Is initialized by `tour` function.
#let tour_default = (
    /// Template configuration. Generated from `conf` function arguments and
    /// defaults.
    /// @type dict
    conf : (
        /// Title of tour.
        /// @type content | none
        title: none,

        /// Show score table for this tour. Overwrites `ctx.show_tour_score_table` if set.
        /// @type bool | none
        show_score_table: none,

        /// Show ans table for this tour. Overwrites `ctx.show_tour_ans_table` if set.
        /// @type bool | none
        show_ans_table: none,
    ),

    /// Internal data.
    /// @type dict
    data: (
        /// Array of tasks.
        /// @type array<task>
        tasks: ()
    )
)
