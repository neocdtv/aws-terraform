
exports.handler = async function(event, context) {
  console.log("Callee triggered...");
  await sleep(8000)
  console.log("Callee finishing...");
  return context.logStreamName
}

function sleep(ms) {
  return new Promise((resolve) => {
    setTimeout(resolve, ms);
  });
}