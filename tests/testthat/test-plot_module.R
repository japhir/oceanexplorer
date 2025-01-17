library(shinytest)

test_that("module for plotting works", {

  skip_on_cran()
  skip_on_ci()
  skip_if_offline()


  appdir <- test_path("apps", "plot_module")
  shinytest::expect_pass(shinytest::testApp(appdir, compareImages = FALSE))
})

