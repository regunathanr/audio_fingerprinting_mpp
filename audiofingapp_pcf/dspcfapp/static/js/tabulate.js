// The table generation function
function tabulate(data, columns) {
    //document.getElementById("sndcldurl").value = ""+data[0].week_id;
    //d3.select("#anomaliestable").append("h4").html("Anomalous users for week: "+ data[0].week_id +"\<br>");  

    //document.getElementById("selectedaccid").value = ""+data[0].selected_acc_id;
    

    var table = d3.select("body").append("table")
            .attr("style", "margin-left: 250px")
            .style("border-collapse", "collapse")
            .style("border", "2px black solid"), 
        thead = table.append("thead"),
        tbody = table.append("tbody");

    // append the header row
    thead.append("tr")
        .selectAll("th")
        .data(columns)
        .enter()
        .append("th")
            .text(function(column) { return column; });

    // create a row for each object in the data
    var rows = tbody.selectAll("tr")
        .data(data)
        .enter()
        .append("tr");

    // create a cell in each row for each column
    var cells = rows.selectAll("td")
        .data(function(row) {
            return columns.map(function(column) {
                return {column: column, value: row[column]};
            });
        })
        .enter()
        .append("td")
        .attr("style", "font-family: Courier") // sets the font style
            .html(function(d) { return d.value; });
    
    return table;
}

