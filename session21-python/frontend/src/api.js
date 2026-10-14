export async function request(path, options = {}) {
  let response, data;
  try {
    response = await fetch(path, {
      ...options,
      signal: options.signal
        ? AbortSignal.any([options.signal, AbortSignal.timeout(15000)])
        : AbortSignal.timeout(15000),
      headers: { "Content-Type": "application/json", ...options.headers },
    });
    // Reading the body can fail or time out even after fetch returns headers.
    if (response.status !== 204) data = await response.json();
  } catch (error) {
    if (options.signal?.aborted) throw error;
    if (response && !response.ok) {
      throw new Error("Server request failed. Refresh the ledger before retrying.");
    }
    const mutation = options.method && !["GET", "HEAD"].includes(options.method.toUpperCase());
    throw new Error(mutation
      ? "Request outcome unknown. Close this dialog and refresh the ledger before retrying."
      : "Could not read the server response. Check the connection and try again.");
  }
  if (!response.ok) {
    const detail = data?.detail;
    const message = Array.isArray(detail)
      ? detail.map(error => {
          if (typeof error?.msg !== "string") return "";
          const field = Array.isArray(error.loc) ? error.loc.at(-1) : null;
          return field ? field + ": " + error.msg : error.msg;
        }).filter(Boolean).join("; ")
      : typeof detail === "string" ? detail : "";
    throw new Error(message || "Request failed. Refresh the ledger before retrying.");
  }
  return response.status === 204 ? null : data;
}
