$(document).ready(function () {
    //GetScoreCardDropDown();
    var usercompanyId = $("#hdnUserCompanyId").val();
    GetCompanyDropDown(usercompanyId);


    GetScoreCardDropDown(usercompanyId);
    //$('#ddlCompany option[value="2"]').attr("selected", "selected");
    //$('#ddlCompany option[value="1"]').attr("selected", true);
    
    //alert("user company Id : " + usercompanyId);
});
function GetCompanyDropDown(usercompanyId) {
  //  alert("company dd");
    $.ajax({
        type: "GET",
        url: "../Audit/GetCompaniesList",
        // data: '{name: "abc" }',
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (data) {
            $("#ddlCompany").append('');
            var optionhtml1 = '<option value="' + 0 + '">' + "Select Company" + '</option>';
            $("#ddlCompany").append(optionhtml1);
            $.each(data, function (index, element) {
                var optionhtml = '<option value="' +
                    element.CompanyID + '">' + element.CompanyName + '</option>';
                $("#ddlCompany").append(optionhtml);
            });
            $('#ddlCompany').val(usercompanyId).attr("selected", "selected");
           
        },
        failure: function () {
        }
    });
}

$("#ddlCompany").change(function () {
     debugger
    var ddlCompanyId = $('option:selected', this).val();
    //var ddlCompanyId = $("#hdnUserCompanyId").val();

   
    //alert("ddlCompanyId : " + ddlCompanyId);

    GetScoreCardDropDown(ddlCompanyId);

});


function GetScoreCardDropDown(id) {
   // alert("score card dd");
   // alert(id);
    $.ajax({
        type: "GET",
        url: "/Audit/GetScoreCardList",
        data: { companyId: id },
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (data) {
            //console.log(data);
            //alert();
            $("#ddlScoreCard").append('');
            var optionhtml1 = '<option value="' + 0 + '">' + "Select Score Card" + '</option>';
            //$("#ddlScoreCard").append(optionhtml1);

            $.each(data, function (index, element) {
                optionhtml1 = optionhtml1 + '<option value="' +
                    element.ScorecardID + '">' + element.ScorecardName + '</option>';

            });
            $("#ddlScoreCard").html(optionhtml1);
        },
        failure: function () {
            //alert("Failed!");
        }
    });
}


//$("#ddlScoreCard111").change(function () {

  function GetAudit(scname) {
      var scorecardText = scname; //$('option:selected', this).text();
    //GetParamType
    //alert(ParamId);
    $.ajax({
        type: "post",
        url: "/Audit/ScoreCardbyidDetails",
        //contentType: 'application/json; charset=utf-8',
        data: { 'ScoreCardNameTxt': scorecardText },
        // data: { 'sectionName': SectionName, 'weightage': Weightage, 'scorecardName': scoreCardName },
        contentType: 'application/x-www-form-urlencoded',
        datatype: "html",
        //data :""
        // dataType: "json" ,
        // console.log(response);

        success: function (response) {
            console.log(response);

            console.log(response.ScoreMasterListViewModel);

            table = $('#Scorecarddetailstbl').DataTable({
                "data": response,
                //"filter": true, // this is for disable filter (search box)
                "processing": true, // for show progress bar
                "orderMulti": false, // for disable multiple column at once
                //"serverSide": true,
                "paging": true,
                "sort": false,
                //"scrollY":400,
                "searching": false,
                "orderCellsTop": true,
                "autoWidth": false,
                "deferRender": true,
                "bDestroy": true,

                columns: [

                    { data: 'SectionName' },
                    { data: 'ParamTitle' },
                    //{ data: 'ParamType' },
                    {
                        data: 'ParamType', 'width': '100px', 'render': function (data, type, row) {
                            if (row.ParamType == 'List' || row.ParamType == 'SList')  {
                                var str = '<select id="ddlParamId" data-id="' + row.scQuestionID + '" name="cars" id="cars">';
                                str = str + '<option value = "Select">Select</option>';
                                str = str + '</select >';
                                return str;
                            }
                            else {
                                var str1 = '<input type="text" id="lname" name="lname">';
                                return str1;
                            }

                        }
                    },


                    { data: 'QWght' },
                ]
            });


        },

        error: function () {
            //alert("Error occured!!")
        }

    });

}
//);

$(document).on('click', '#ddlParamId', function () {

    var id = $(this).attr("data-id");

    //alert("id :" + id);


    $.ajax({
        type: "GET",
        url: "/Audit/GetQuestionsValuesList",
        data: { companyId: id },
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (data) {
            var optionhtml1 = '<option value="' + 0 + '">' + "Select Score Card" + '</option>';
            $("#ddlScoreCard").append(optionhtml1);

            $.each(data, function (index, element) {
                var optionhtml = '<option value="' +
                    element.ScorecardID + '">' + element.ScorecardName + '</option>';
                $("#ddlScoreCard").append(optionhtml);
            });
        },
        failure: function () {
            //alert("Failed!");
        }
    });
});

$(document).on('click', '#btnsubmit', function () {
    debugger;
    var responce = [];
    var comments = [];
    var qwscore = [];
    var score = [];
    var staticSectionVal = [];
    var adscore = 0;
    var companyid = $("#ddlCompany").val();
    var scorecardid = $("#ddlScoreCard").val();

    var req_result = checkvalidation();
    if (req_result == false) {
        toastr.warning('Please enter required values', 'Warning Alert', { timeOut: 3000 });
    } else {
        //alert("satya");
        $('.sectionIdcls').each(function () {
            var secTextVal = 0;
            
            //alert("secText : " + $(this).text());
            if ($(this).text() != "") {
                secTextVal = $(this).text();
                adscore = parseFloat(secTextVal) + adscore;
            }
            var secValue = $(this).attr("data-sectionId") + "-" + secTextVal;
            staticSectionVal.push(secValue);
            alert("Total Score");
            $("#txtGSC").val(adscore);
        });

        $('.clsqwgetdate').each(function () {
            if ($(this).attr("data-type") == "S") {
                var rvalue = $(this).attr("data-id") + "-" + $(this).val();
                qwscore.push(rvalue);
            }
        });
        //
        $('.clsgetdata').each(function () {
            if ($(this).attr("data-type") == "R") {
                var rvalue = $(this).attr("data-id") + "-" + $(this).val();
                responce.push(rvalue);
            }
            if ($(this).attr("data-type") == "M") {
                var ival = $(this).attr("data-id");
                if ($("#ddl_" + ival + " :selected").val() != "") {
                    var rvalue = $(this).attr("data-id") + "-" + $("#ddl_" + ival + " :selected").text() + "-" + $("#ddl_" + ival + " :selected").val();
                    responce.push(rvalue);
                }
            }
            if ($(this).attr("data-type") == "C") {
                if ($(this).val() != "") {
                    var cvalue = $(this).attr("data-id") + "-" + $(this).val();
                    comments.push(cvalue);
                }
            }

        });



        var dataItem = {
            CompanyId: companyid,
            ScorecardID: scorecardid,
            Responce: responce.join(","),
            Comments: comments.join(","),
            QScore: qwscore.join(","), 
            Score: score,
            Type: "1",
            SectionIdValues: staticSectionVal.join(",")
        };
        console.log(dataItem);
        setTimeout(function () {
            $.ajax({
                url: '../Audit/SaveDraftAuditDetails',
                type: "Post",
                data: dataItem,
                success: function (response) {
                    // alert("Audit deatils added successfully");
                    toastr.success('Audit details saved successfully.', 'Success Alert', { timeOut: 2000 });
                    setTimeout(function () {
                        //window.location.reload();
                        $('#btnsubmit').prop('disabled', true);
                        $('#btndraft').prop('disabled', true);
                    }, 3000);
                }
            });

        }, 3000);

    }
});

$(document).on('click', '#btndraft', function () {
    debugger;
    var responce = [];
    var comments = [];
    var score = [];
    var staticSectionVal = [];
    var companyid = $("#ddlCompany").val();
    var scorecardid = $("#ddlScoreCard").val();
    var req_result = checkvalidation();
    if (req_result == false) {
        //alert("Please enter required values");
        toastr.warning('Please enter required values', 'Warning Alert', { timeOut: 2000 });
    } else {
        $('.sectionIdcls').each(function () {
            var secTextVal = 0;
            var scaval = 0;
            //alert("secText : " + $(this).text());
            if ($(this).text() != "") {
                secTextVal = $(this).text();
                var scaval = $("#txtGSC").val();
                $("#txtGSC").val(parseInt(secTextVal) + parseInt(scaval));
            }
            var secValue = $(this).attr("data-sectionId") + "-" + secTextVal;
            staticSectionVal.push(secValue);
            alert("Audit Score :" + $("#txtGSC").val());
        });
        $('.clsgetdata').each(function () {
            if ($(this).attr("data-type") == "R") {
                var rvalue = $(this).attr("data-id") + "-" + $(this).val();
                responce.push(rvalue);
            }
            if ($(this).attr("data-type") == "M") {
                var ival = $(this).attr("data-id");
                if ($("#ddl_" + ival + " :selected").val() != "") {
                    var rvalue = $(this).attr("data-id") + "-" + $("#ddl_" + ival + " :selected").text();
                    responce.push(rvalue);
                }
            }
            if ($(this).attr("data-type") == "C") {
                if ($(this).val() != "") {
                    var cvalue = $(this).attr("data-id") + "-" + $(this).val();
                    comments.push(cvalue);
                }
            }
        });
        var dataItem = {
            CompanyId: companyid,
            ScorecardID: scorecardid,
            Responce: responce.join(","),
            Comments: comments.join(","),
            Score: score,
            Type: "0",
            SectionIdValues: staticSectionVal.join(",")
        };
        console.log(dataItem);
        $.ajax({
            url: '../Audit/SaveDraftAuditDetails',
            type: "Post",
            data: dataItem,
            success: function (response) {
                //alert("Audit deatils draft successfully");
                toastr.success('Audit details drafted successfully.', 'Success Alert', { timeOut: 2000 });
                setTimeout(function () {
                    //window.location.reload();
                    $('#btnsubmit').prop('disabled', true);
                    $('#btndraft').prop('disabled', true);
                }, 3000);
            }
        });
    }
});
