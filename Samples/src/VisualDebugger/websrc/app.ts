import "./css/main.css";
import * as signalR from "@aspnet/signalr";
import * as chart from "chart.js";

//#region Serialization contract

type State = {
    real: number,
    imaginary: number,
    magnitude: number,
    phase: number
}[];

//#endregion

//#region HTML elements

const olOperations: HTMLDivElement = document.querySelector("#olOperations");
const btnStepIn: HTMLButtonElement = document.querySelector("#btnStepIn");
const btnStepOver: HTMLButtonElement = document.querySelector("#btnStepOver");
const btnPrevious: HTMLButtonElement = document.querySelector("#btnPrevious");
const canvas: HTMLCanvasElement = document.querySelector("#chartCanvas");
const chartContext = canvas.getContext("2d");

//#endregion

const operations: HTMLLIElement[] = [];

type Snapshot = {
    state: State,
    lastOperation: HTMLLIElement,
    nextOperation: HTMLLIElement
};

type History = {
    snapshots: Snapshot[],
    position: number
};

const history: History = {
    snapshots: [],
    position: -1
};

const stateChart = new chart.Chart(chartContext, {
    type: "bar",
    data: {
        labels: [],
        datasets: [
            {
                data: [],
                label: "Real",
				backgroundColor: "#ff0000",
				borderColor: "#ff0000",
            },
            {
                data: [],
                label: "Imag",
				backgroundColor: "#0000ff",
				borderColor: "#0000ff",
            }
        ]
    },
    options: {
        responsive: true,
        maintainAspectRatio: false,
        scales: {
            yAxes: [
                {
                    ticks: {
                        suggestedMin: -1,
                        suggestedMax: 1
                    }
                }
            ]
        }
    }
});

function updateChart(state: State) {
    let real = state.map(amplitude => amplitude.real);
    let imag = state.map(amplitude => amplitude.imaginary);
    let newCount = real.length;
    let nQubits = Math.log2(newCount) >>> 0;
    stateChart.data.datasets[0].data = real;
    stateChart.data.datasets[1].data = imag;
    stateChart.data.labels = Array.from(Array(state.length).keys()).map(idx => {
        let bitstring = (idx >>> 0).toString(2).padStart(nQubits, "0");
        return `|${bitstring}⟩`;
    });
    stateChart.update();
}

function goToHistory(position: number): void {
    const lastSnapshot = history.snapshots[history.position];
    if (lastSnapshot.lastOperation !== null) {
        lastSnapshot.lastOperation.className = "";
    }
    if (lastSnapshot.nextOperation !== null) {
        lastSnapshot.nextOperation.className = "";
    }

    const nextSnapshot = history.snapshots[position];
    if (nextSnapshot.lastOperation !== null) {
        nextSnapshot.lastOperation.className = "last";
    }
    if (nextSnapshot.nextOperation !== null) {
        nextSnapshot.nextOperation.className = "next";
    }
    history.position = position;
    updateChart(nextSnapshot.state);
}

function pushHistory(lastOperation: HTMLLIElement, nextOperation: HTMLLIElement, state: State): void {
    if (state === null) {
        state = history.snapshots.length === 0 ? [] : history.snapshots[history.snapshots.length - 1].state;
    }
    history.snapshots.push({ state, lastOperation, nextOperation });
    history.position = history.snapshots.length - 1;
}

function clearLastOperation(): void {
    if (operations.length > 0) {
        operations[operations.length - 1].className = "";
    }
    const last = olOperations.querySelector(".last");
    if (last !== null) {
        last.className = "";
    }
}

function getCurrentOperation(): HTMLLIElement {
    const snapshot = history.snapshots[history.position];
    return snapshot.nextOperation !== null ? snapshot.nextOperation : snapshot.lastOperation;
}

function getLevel(operation: HTMLLIElement): number {
    if (operation.parentElement === null) {
        throw new Error("Operation is not in olOperations");
    } else if (operation.parentElement === olOperations) {
        return 0;
    } else if (operation.parentElement.parentElement instanceof HTMLLIElement) {
        return 1 + getLevel(operation.parentElement.parentElement);
    }
}

//#region SignalR hub connection

const connection = new signalR.HubConnectionBuilder()
    .withUrl("/events")
    .build();

connection.start().catch(err => document.write(err));

connection.on("OperationStarted", onOperationStarted);
connection.on("OperationEnded", onOperationEnded);

function onOperationStarted(operationName: string, input: number[]) {
    console.log("Operation start:", operationName, input);

    clearLastOperation();
    const operation = document.createElement("li");
    operation.className = "next";
    operation.innerHTML =
        `<span class="operation-name">${operationName}</span>` +
        `(<span class="operation-args">${input.join(", ")}</span>)` +
        `<ol class="operation-children"></ol>`;

    if (operations.length == 0) {
        olOperations.appendChild(operation);
    } else {
        operations[operations.length - 1].querySelector(".operation-children").appendChild(operation);
    }
    olOperations.scrollTop = olOperations.scrollHeight;
    operations.push(operation);
    pushHistory(null, operation, null);
}

function onOperationEnded(output: any, state: State) {
    console.log("Operation end:", output);

    clearLastOperation();
    const operation = operations.pop();
    operation.className = "last";

    // Show only return values that aren't unit.
    if (!(output instanceof Object) || Object.keys(output).length > 0) {
        operation.appendChild(document.createTextNode(` = ${output}`));
    }

    updateChart(state);
    pushHistory(operation, null, state);
    olOperations.scrollTop = olOperations.scrollHeight;
}

function nextEvent(): Promise<void> {
    return new Promise((resolve, reject) => {
        function finish(): void {
            resolve();
            connection.off("OperationStarted", finish);
            connection.off("OperationEnded", finish);
        }

        if (operations.length === 0) {
            reject("All operations have finished");
        } else {
            connection.on("OperationStarted", finish);
            connection.on("OperationEnded", finish);
        }
    });
}

//#endregion

async function next(): Promise<void> {
    if (history.position == history.snapshots.length - 1) {
        if (operations.length > 0) {
            connection.invoke("Advance");
            await nextEvent();
        }
    } else {
        goToHistory(history.position + 1);
    }
}

async function previous(): Promise<void> {
    // This is only async for symmetry with next, which needs to be async.
    if (history.position > 0) {
        goToHistory(history.position - 1);
    }
}

async function repeatUntil(step: () => Promise<void>, success: () => boolean): Promise<void> {
    const before = history.position;  // Make sure we're making progress each step.
    await step();
    if (history.position !== before && !success()) {
        await repeatUntil(step, success);
    }
}

function jump(event: Event): void {
    let operation: HTMLLIElement;
    if (event.target instanceof HTMLLIElement) {
        operation = event.target;
    } else if (event.target instanceof HTMLSpanElement && event.target.parentElement instanceof HTMLLIElement) {
        operation = event.target.parentElement;
    } else {
        return;
    }
    const position = history.snapshots.findIndex(snapshot => operation === snapshot.nextOperation);
    if (position !== -1) {
        goToHistory(position);
    }
}

function isOperationStart(): boolean {
    return history.snapshots[history.position].nextOperation !== null;
}

btnStepIn.addEventListener("click", () => repeatUntil(next, isOperationStart));
btnStepOver.addEventListener("click", () => {
    const level = getLevel(getCurrentOperation());
    repeatUntil(next, () => isOperationStart() && getLevel(getCurrentOperation()) <= level);
});
btnPrevious.addEventListener("click", () => repeatUntil(previous, isOperationStart));
olOperations.addEventListener("click", jump);
