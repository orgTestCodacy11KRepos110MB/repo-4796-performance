if (requiet("glmmTMB") && getRversion() >= "4.0.0") {
  data(Salamanders)
  m1 <- glmmTMB(count ~ spp + mined + (1 | site),
    ziformula = ~spp,
    Salamanders,
    family = poisson()
  )

  test_that("check_collinearity", {
    expect_equal(
      suppressWarnings(check_collinearity(m1, component = "conditional", verbose = FALSE)$VIF),
      c(1.00037354840318, 1.00037354840318),
      tolerance = 1e-3
    )
    expect_equal(
      suppressWarnings(check_collinearity(m1, component = "all", verbose = FALSE)$VIF),
      c(1.00037354840318, 1.00037354840318),
      tolerance = 1e-3
    )
    expect_null(suppressWarnings(check_collinearity(m1, component = "zero_inflated")))
  })

  m2 <- glmmTMB(
    count ~ spp + mined + cover + (1 | site),
    ziformula = ~ spp + mined + cover,
    family = nbinom2,
    data = Salamanders
  )

  test_that("check_collinearity", {
    expect_equal(
      suppressWarnings(check_collinearity(m2, component = "conditional", verbose = FALSE)$VIF),
      c(1.09015, 1.2343, 1.17832),
      tolerance = 1e-3
    )
    expect_equal(
      suppressWarnings(check_collinearity(m2, component = "conditional", verbose = FALSE)$VIF_CI_low),
      c(1.03392, 1.14674, 1.10105),
      tolerance = 1e-3
    )
    expect_equal(
      suppressWarnings(check_collinearity(m2, component = "all", verbose = FALSE)$VIF),
      c(1.09015, 1.2343, 1.17832, 1.26914, 1, 1.26914),
      tolerance = 1e-3
    )
    expect_equal(
      suppressWarnings(check_collinearity(m2, component = "all", verbose = FALSE)$VIF_CI_low),
      c(1.03392, 1.14674, 1.10105, 1.17565, 1, 1.17565),
      tolerance = 1e-3
    )
    expect_equal(
      suppressWarnings(check_collinearity(m2, component = "zero_inflated", verbose = FALSE)$VIF),
      c(1.26914, 1, 1.26914),
      tolerance = 1e-3
    )
    expect_equal(
      suppressWarnings(check_collinearity(m2, component = "zero_inflated", verbose = FALSE)$Tolerance_CI_high),
      c(0.85059, 1, 0.85059),
      tolerance = 1e-3
    )

    suppressWarnings(coll <- check_collinearity(m2, component = "all", verbose = FALSE))
    expect_true(all(coll$Tolerance < coll$Tolerance_CI_high))
    expect_true(all(coll$VIF > coll$VIF_CI_low))

    expect_identical(
      attributes(coll)$data$Component,
      c("conditional", "conditional", "conditional", "zero inflated", "zero inflated", "zero inflated")
    )
    expect_identical(
      colnames(attributes(coll)$CI),
      c("VIF_CI_low", "VIF_CI_high", "Tolerance_CI_low", "Tolerance_CI_high", "Component")
    )
  })

  if (requiet("afex") && utils::packageVersion("afex") >= package_version("1.0.0")) {
    test_that("check_collinearity | afex", {
      data(obk.long, package = "afex")

      obk.long$treatment <- as.character(obk.long$treatment)
      suppressWarnings(suppressMessages({
        aM <- afex::aov_car(value ~ treatment * gender + Error(id / (phase * hour)),
          data = obk.long
        )

        aW <- afex::aov_car(value ~ Error(id / (phase * hour)),
          data = obk.long
        )

        aB <- afex::aov_car(value ~ treatment * gender + Error(id),
          data = obk.long
        )
      }))

      expect_message(ccoM <- check_collinearity(aM))
      expect_warning(expect_message(ccoW <- check_collinearity(aW)))
      expect_message(ccoB <- check_collinearity(aB), regexp = NA)

      expect_identical(nrow(ccoM), 15L)
      expect_identical(nrow(ccoW), 3L)
      expect_identical(nrow(ccoB), 3L)

      suppressWarnings(suppressMessages({
        aM <- afex::aov_car(value ~ treatment * gender + Error(id / (phase * hour)),
          include_aov = TRUE,
          data = obk.long
        )

        aW <- afex::aov_car(value ~ Error(id / (phase * hour)),
          include_aov = TRUE,
          data = obk.long
        )

        aB <- afex::aov_car(value ~ treatment * gender + Error(id),
          include_aov = TRUE,
          data = obk.long
        )
      }))

      expect_message(ccoM <- check_collinearity(aM))
      expect_warning(expect_message(ccoW <- check_collinearity(aW)))
      expect_message(ccoB <- check_collinearity(aB), regexp = NA)

      expect_identical(nrow(ccoM), 15L)
      expect_identical(nrow(ccoW), 3L)
      expect_identical(nrow(ccoB), 3L)
    })
  }

  test_that("check_collinearity, ci = NULL", { # 518
    data(npk)
    m <- lm(yield ~ N + P + K, npk)
    out <- check_collinearity(m, ci = NULL)

    expect_identical(
      colnames(out),
      c(
        "Term", "VIF", "VIF_CI_low", "VIF_CI_high", "SE_factor", "Tolerance",
        "Tolerance_CI_low", "Tolerance_CI_high"
      )
    )
    expect_snapshot(print(out))
  })
}
