// Get all school names from the dashboard. Result is used to verify if the download was successful.
//
// Usage: copy and paste code below inside console on either
//
// https://scotland.shinyapps.io/sg-primary_school_information_dashboard/
// or
// https://scotland.shinyapps.io/sg-secondary_school_information_dashboard/
//
// Once run copy the resulting object from the console.
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

async function run() {
    let result = {};

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

            await timeout(2500);
            let schoolButton = document.getElementById("sidebar-la_school_filter-school-selectized");
            await schoolButton.click();
            await waitForSpinner();

            let selectors = null;

            while (!selectors) {
                await timeout(2500);
                schoolButton = document.getElementById("sidebar-la_school_filter-school-selectized");
                selectors = schoolButton?.parentElement?.nextElementSibling?.childNodes[0];
            }

            let schools = [...selectors.childNodes].map(n => [n.id, n.innerText])

            result[authority[1]] = schools.map(s => s[1]);
        } else {
            console.log(`Skipping ${authority[1]}`);
        }
    }

    console.log(result);
    console.log(JSON.stringify(result));
}

run();
