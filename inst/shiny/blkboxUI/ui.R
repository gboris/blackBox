library(shiny)
library(shinyjs)
# To-Do -------------------------------------------*
# Visualisation Pane
#   - "Use Exisiting Model"
#       - find those objects with class blkbox
#   - "Performance"
#   - "ROC Curve"
#   - "Feature Importance Curves"
#       - Option to show where AUC line is? [Extra]
#   -
#
# -------------------------------------------------*

# Define UI for application that draws a histogram
shinyUI(fluidPage( theme = "style.css",

                   shinyjs::useShinyjs(),

    absolutePanel(id = "panel1", width = "auto",
    # ---------------------------------------------------------------------------------------
    h1(id = "header", icon("square", "fa-6x"), "blkbox"),
    div(id = "Wrapper",
    div(id = "varSel",
    wellPanel(id = "top_panel",
    # Select Data & Labels ------------------------------------------------------------------
    uiOutput("data_selection"),
    uiOutput("label_selection"),
    # Select Type of Model ------------------------------------------------------------------
    selectInput("model_type", label = "Model Type:", width = "240px",
                choices = c("-- Select Model Type --" = 0,
                "Training & Testing" = 1,
                "Cross-fold Validation" = 2,
                "Nested Cross-fold Validation" = 3)),
    # Name output ---------------------------------------------------------------------------
    textInput("model_name", "Output Name:", width = "240px", placeholder = "e.g. blkbox_results", value = "blkbox_results")),
    #----------------------------------------------------------------------------------------
    # When View pane is toggeled on
    hidden(
      wellPanel(id = "visualis_opts",
                uiOutput("results_vis"),
                selectInput("vis_type", label = "Visualisation:", width = "240px",
                            choices = c("--Choose Visualisation--",
                                        "Model Performance")),
                hidden(
                  uiOutput("perf_vis_opts")
                )
        )
    ),
    #----------------------------------------------------------------------------------------
    # Training & Testing --------------------------------------------------------------------
    conditionalPanel(condition = "input.model_type == 1",
                     wellPanel(id = "TT",
                     # Partition Data -------------------------------------------------------
                     sliderInput(inputId = "partition_slider", label = "Partition Ratio",
                                 min = 0.1, max = 0.95, value = 0.8, step = 0.01, ticks = F,
                                 width = "240px"),
                     # Partiton Seed --------------------------------------------------------
                     checkboxInput(inputId = "partition_seed_ask", label = "Use seed for Partition?", value = F),
                     conditionalPanel(condition = "input.partition_seed_ask == true",
                                      numericInput(inputId = "partition_seed",
                                                   label = "Partition Seed:",
                                                   min = 0, step = 1, value = NA, width = "240px"))
                     )),
    # Cross-fold Validation -----------------------------------------------------------------
    conditionalPanel(condition = "input.model_type == 2",
                     wellPanel(id = "CV",
                     splitLayout(cellWidths = "120px",
                     # Number of Folds ------------------------------------------------------
                     numericInput(inputId = "fold_number", label = "Folds:",
                                  min = 2, step = 1, max = 20, value = 10, width = "105px"),
                     # Number of Repeats ----------------------------------------------------
                     numericInput(inputId = "cv_repeat_number", label = "Repeats:",
                                  min = 1, step = 1, max = 50, value = 1, width = "105px")
                     ),
                     # Feature Selection of Data? -------------------------------------------
                     # AUC Cutoff -----------------------------------------------------------
                     sliderInput(inputId = "cv_auc_slider", label = "AUC Feature Cutoff:",
                                 min = 0.05, max = 1.00, value = 0.5, step = 0.01, ticks = F,
                                 width = "240px"),
                     # Feature Selection Method ---------------------------------------------
                     selectInput(inputId = "cv_method", label = "Feature Selection Method:",
                                 selected = "GLM", multiple = F, width = "240px",
                                 choices = c("random forest" = "randomforest",
                                             "k-nearest neighbours" = "knn",
                                             "glmnet" = "GLM",
                                             "SVM",
                                             "xgboost",
                                             "party",
                                             "neural net" = "nnet",
                                             "BART" = "bartmachine",
                                             "Shrunken-Centroid" = "PamR"))
                     )),
    # Nested Cross-fold Validation ----------------------------------------------------------
    conditionalPanel(condition = "input.model_type == 3",
                     wellPanel(id = "NCV",
                     splitLayout(cellWidths = "120px",
                     # Number of Inner Folds ------------------------------------------------
                     numericInput(inputId = "inner_folds", label = "Inner Folds:",
                                  min = 2, step = 1, max = 20, value = 10, width = "105px"),
                     # Number of Outer Folds ------------------------------------------------
                     numericInput(inputId = "outer_folds", label = "Outer Folds:",
                                  min = 2, step = 1, max = 20, value = 10, width = "105px")
                     ),
                     # Number of Repeats ----------------------------------------------------
                     numericInput(inputId = "ncv_repeat_number", label = "Repeats:",
                                  min = 1, step = 1, max = 50, value = 1, width = "240px"),
                     # Feature Selection of Data? -------------------------------------------
                     # AUC Cutoff -----------------------------------------------------------
                     sliderInput(inputId = "ncv_auc_slider", label = "AUC Feature Cutoff:",
                                 min = 0.05, max = 1.00, value = 0.5, step = 0.01, ticks = F,
                                 width = "240px"),
                     # Feature Selection Method ---------------------------------------------
                     selectInput(inputId = "ncv_method", label = "Feature Selection Method:",
                                 selected = "GLM", multiple = F, width = "240px",
                                 choices = c("random forest" = "randomforest",
                                             "k-nearest neighbours" = "knn",
                                             "glmnet" = "GLM",
                                             "SVM",
                                             "xgboost",
                                             "party",
                                             "neural net" = "nnet",
                                             "BART" = "bartmachine",
                                             "Shrunken-Centroid" = "PamR"))
                     )),
    # Options -------------------------------------------------------------------------------
    conditionalPanel(condition = "input.model_type != 0",
    # Exclude Algorithms --------------------------------------------------------------------
    wellPanel(id = "exclude_opts",
    selectInput(inputId = "exclude_alg", label = "Exclude Algorithms", multiple = T,
                selected = 0, width = "240px",
                choices = c("None" = 0,
                            "random forest" = "randomforest",
                            "k-nearest neighbours" = "knn",
                            "glmnet" = "GLM",
                            "SVM",
                            "xgboost",
                            "party",
                            "neural net" = "nnet",
                            "BART" = "bartmachine",
                            "Shrunken-Centroid" = "PamR")),
                splitLayout(
                # Want to use a seed? ------------------------------------------------------
                checkboxInput(inputId = "seed_ask", label = "Use Seed?", value = F),
                # Choose a seed ------------------------------------------------------------
                conditionalPanel(condition = "input.seed_ask == true",
                      numericInput(inputId = "seed", label = "Seed:",
                                   min = 1, step = 1, value = NA, width = "105px")
                )),
    checkboxInput(inputId = "options", label = "Advanced Paramters", value = F))),
    # Algorithm Specific Options -----------------------------------------------------------
    div(id = "hide_div",
    conditionalPanel(condition = "input.model_type != 0 & input.options == true",

                     # Tree based algorithms -----------------------------------------------
                     conditionalPanel(condition =  "input.exclude_alg.indexOf('randomforest') == -1 ||
                                                    input.exclude_alg.indexOf('party') == -1 ||
                                                    input.exclude_alg.indexOf('bartmachine') == -1",
                                     wellPanel(
                                     splitLayout(
                                     # Number of Trees ------------------------------------
                                     numericInput(inputId = "ntree", label = "No. Trees:",
                                                  min = 10, step = 10, max = 20000, value = 500,
                                                  width = "105px"),
                                     # Number of Features @ Node ---------------------------
                                     numericInput(inputId = "mtry", label = "Node Size:",
                                                  min = 2, step = 1, max = 10000, value = NA,
                                                  width = "105px")))),
                     # SVM -----------------------------------------------------------------
                     conditionalPanel(condition =  "input.exclude_alg.indexOf('SVM') == -1",
                                      wellPanel(
                                      selectInput(inputId = "svm_kernel", label = "SVM Kernel:",
                                                  choices = c("linear", "radial", "sigmoid", "polynomial"),
                                                  selected = "linear", multiple = F, selectize = T),
                                      # Gamma -----------------------------------------------
                                      numericInput(inputId = "svm_gamma", label = "SVM Gamma:",
                                                   min = 1e-3, step = 1e-2, max = 1, value = NA)
                                      )),
                     # xgboost --------------------------------------------------------------
                     conditionalPanel(condition =  "input.exclude_alg.indexOf('xgboost') == -1",
                                      wellPanel(
                                      numericInput(inputId = "max_depth", label = "xgboost max depth:",
                                                   min = 1, step = 1, max = 20000, value = NA)))
                     )),
    # Submit/Run ---------------------------------------------------------------------------
    actionButton(inputId = "submit_model", label = "Process", icon = icon("cogs", "fa"), width = "118px"),
    actionButton(inputId = "get_code", label = "Get Code", icon = icon("terminal", "fa"), width = "118px"),
    actionButton(inputId = "viewpane_on", label = "Results Viewer", icon = icon("area-chart", "fa"), width = "240px"),
    hidden(
      actionButton(inputId = "model_on", label = "Model Generation", icon = icon("sliders", "fa"), width = "240px")
    ),
    # Code Display -------------------------------------------------------------------------
    hidden(
      wellPanel(id = "code_well",
        textOutput("code")
      )
    )),
    # Performance --------------------------------------------------------------------------
    hidden(
    div(id = "viewpane",
         wellPanel(id ="xxx",
           plotOutput("temp_plot")
         )
        )
    )
    )
    )

))
