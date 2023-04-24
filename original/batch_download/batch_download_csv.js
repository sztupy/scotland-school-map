// Batch download school data from the dashboards. Unfortunately there is no way
// to download all data in one go, only by going school-to-school one-by-one.
// This script will just do that automatically.
//
// Usage: copy and paste code below inside console on either
//
// https://scotland.shinyapps.io/sg-primary_school_information_dashboard/
// or
// https://scotland.shinyapps.io/sg-secondary_school_information_dashboard/
//
// Download will take around an hour for secondary, 2-3 for primary school data
//
// Tested with Firefox 112.01

function timeout(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function waitForSpinner() {
    while (!document.querySelector(".shiny-spinner-hidden")) {
        await timeout(1000);
    }
}

async function downloadBatch() {
    await timeout(10000);
    let schoolButton = document.getElementById("sidebar-la_school_filter-school-selectized");
    await schoolButton.click();
    await waitForSpinner();

    let selectors = null;

    while (!selectors) {
        await timeout(10000);
        schoolButton = document.getElementById("sidebar-la_school_filter-school-selectized");
        selectors = schoolButton?.parentElement?.nextElementSibling?.childNodes[0];
    }

    let schools = [...selectors.childNodes].map(n => [n.id, n.innerText])

    console.log(schools);

    for (let school of schools) {
        console.log(`Running ${school[1]}`);

        await waitForSpinner();

        await document.getElementById(school[0]).click();

        await waitForSpinner();
        await document.getElementById("pupil_profile-download-button").click();
        await timeout(1000);
        await document.getElementById("attendance-download-button").click();
        await timeout(1000);
        await document.getElementById("population-download-button").click();
        await timeout(1000);
        await document.getElementById("attainment-download-button").click();
        await timeout(1000);
    }
}

async function run() {
    let firstCouncil = 'Scotland';

    let modal = document.querySelector("#shiny-modal .modal-footer .btn-default");

    if (modal) await modal.click();

    let authorityButton = document.getElementById("sidebar-la_school_filter-la-selectized")

    await authorityButton.click();
    await waitForSpinner();

    let selectors = null;

    while (!selectors) {
        await timeout(1000);
        selectors = authorityButton.parentElement.nextElementSibling.childNodes[0];
    }

    let authorities = [...selectors.childNodes].map(n => [n.id, n.innerText])

    let first = false;
    for (let authority of authorities) {
        if (authority[1] == firstCouncil)
            first = true;

        if (first) {
            console.log(`Running ${authority[1]}`);
            await waitForSpinner();
            await document.getElementById(authority[0]).click();
            await downloadBatch();
        } else {
            console.log(`Skipping ${authority[1]}`);
        }
    }
}

run();
