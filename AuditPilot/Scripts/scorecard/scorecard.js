$(document).ready(function () {
    $("#txtlist").val('');
    $(".js-example-tokenizer").select2({
        tags: true,
        tokenSeparators: [',', ' ']
        
    })
    $(".js-select2").select2({
        closeOnSelect: false,
        placeholder: "Placeholder",
        allowHtml: true,
        allowClear: true,
        tags: true // создает новые опции на лету
    });

    $(".icons_select2").select2({
        width: "100%",
        templateSelection: iformat,
        templateResult: iformat,
        allowHtml: true,
        placeholder: "Placeholder",
        dropdownParent: $(".select-icon"), //обавили класс
        allowClear: true,
        multiple: false
    });

    function iformat(icon, badge) {
        var originalOption = icon.element;
        var originalOptionBadge = $(originalOption).data("badge");

        return $(
            '<span><i class="fa ' +
            $(originalOption).data("icon") +
            '"></i> ' +
            icon.text +
            '<span class="badge">' +
            originalOptionBadge +
            "</span></span>"
        );
    }
    $('#dataTables-example').DataTable({
        responsive: true
    });

    //$('#btnAddSection').css("display", "none");
});




function funCreateCard(scoreCardId) {
   alert("scoreCardId222 : " + scoreCardId);

   
    var scoreCardName = $("#ScoreCardNameTxt").val();
    if (scoreCardName == "") {
        $("#SpanCardNameError").text("Scorecard name is required.");
        return false;
    }
    else {
        $("#SpanCardNameError").text("");
        $.ajax({
            type: "POST",
            url: "/Audit/ScoreSave",
            //contentType: 'application/json; charset=utf-8',
            data: { 'ScoreCardNameTxt': scoreCardName, 'scoreCardId': scoreCardId},
            contentType: 'application/x-www-form-urlencoded',
            datatype: "html",

            success: function (data) {
                if (data == true) {
                    //alert("Scorecard name created successfully.");
                    toastr.success('Scorecard name created successfully', 'Success Alert', { timeOut: 3000 });
                    $("#ScoreCardNameTxt").prop("disabled", true);
                    $("#btnScoreCardSave").prop("disabled", true);
                    $('#btnAddSection').css("display", "block");
                    //$("#divsc").load("/Audit/GetScoreCards");
                }
                else {
                    //alert("Scorecard name is already exists.");
                    toastr.warning('Scorecard name is already exists.', 'Warning Alert', { timeOut: 3000 });
                    $("#ScoreCardNameTxt").prop("disabled", true);
                    $("#btnScoreCardSave").prop("disabled", true);
                    $('#btnAddSection').css("display", "block");
                  //  $("#divsc").load("/Audit/GetScoreCards");
                }

                //alert(data.msg);
            },
            error: function () {
                alert("Error occured!!")
            }
        });
    }
   

}

var iTableCounter = 1;

$(function () {
    ////
    
    //GetParamsDropDown();
    $("#btnScoreCardSave").click(function () {
        debugger;
       // $("#divsc").load("/Audit/GetScoreCards");
        var scoreCardName = $("#ScoreCardNameTxt").val();
        if (scoreCardName == "") {
            $("#SpanCardNameError").text("Scorecard name is required.");
            return false;
        }
        else {
            $("#SpanCardNameError").text("");
            $.ajax({
                type: "POST",
                url: "../Audit/ScoreSave",
                //contentType: 'application/json; charset=utf-8',
                data: { 'ScoreCardNameTxt': scoreCardName },
                contentType: 'application/x-www-form-urlencoded',
                datatype: "html",

                success: function (data) {
                    if (data == true) {
                        //alert("Scorecard name created successfully.");
                        toastr.success('Scorecard name created successfully', 'Success Alert', { timeOut: 3000 });
                        $("#ScoreCardNameTxt").prop("disabled", true);
                        $("#btnScoreCardSave").prop("disabled", true);
                        $('#btnAddSection').css("display", "block");
                        }
                    else {
                        //alert("Scorecard name is already exists.");
                        toastr.warning('Scorecard name is opened for edit.', 'Warning Alert', { timeOut: 3000 });
                        $("#ScoreCardNameTxt").prop("disabled", true);
                        $("#btnScoreCardSave").prop("disabled", true);
                        $('#btnAddSection').css("display", "block");
                        debugger;
                        $.ajax({
                            type: "GET",
                            url: "../Audit/GetSections",
                            data: { 'scorecardName': scoreCardName },
                            contentType: 'application/x-www-form-urlencoded',
                            datatype: "html",
                            success: function (response) {

                                $("#Sectiontbl").show();

                                $("#myModal").modal('hide');
                                table = $('#Sectiontbl').DataTable({
                                    "data": response.ScoreMasterListViewModel,
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

                                    columns: [{
                                        className: 'details-control',
                                        orderable: false,
                                        data: null,
                                        defaultContent: ''
                                    },

                                    {
                                        data: 'SectionName', className: 'sorting_1'
                                    },
                                    {
                                        data: 'SectionWght', className: 'sorting_2'
                                    },

                                    {

                                        data: 'Actions', 'width': '50px', 'render': function (data, type, row, meta) {
                                            var str = "";
                                            //return str = '<button type="button" class="btn btn-primary" id="btnSectionSave" click="EditSection();" name="BtnEDitSectionSave">EDIT</button>    <a href="/Audit/DeleteSection/' + row.scSectionID + '" title="Click here to edit category details" id="btnedit" class="getidcls" data-id="' + row.scSectionID + '"> <i class="far fa-edit primary"></i></a>';
                                            return str = '<a href="javascript:void(0);" title="Edit" class="editsname" data-id="' + row.scSectionID + '" data-sname="' + row.SectionName + '" data-swghte="' + row.SectionWght + '"  ><i class="fa fa-pencil-square-o" aria-hidden="true"></i></a> <a href="javascript:void(0);" data-id="' + row.scSectionID + '" class="delete" title="Delete" ><i class="fa fa-times-circle" style="color:red" aria-hidden="true"></i></a> <a href="javascript:void(0);" title="AddParameter" class="AddParm" data-id="' + row.ScorecardID + '" data-name="' + row.scSectionID + '" ><i  class="fa fa-plus"></i></a>';
                                            //< a href = "#" title = "Delete" > <i title="AddPara" class="AddParm" data-id="' + row.ScorecardID + '" data-name="' + row.scSectionID + '" class="far fa-trash-alt text-danger"></i></a > ';
                                        }

                                    }
                                    ]
                                });

                            },
                            error: function () {
                                //alert("Error occured!!")
                            }
                        });
                   
                    }
                     //alert(data.msg);
                },
                error: function (jqXHR, exception) {

                    alert("Error occured!! " + exception + " " + jqXHR.status)
                }
            });





        }
        // document.forms[0].submit();

      

    });


    $("#btnAddSection").click(function () {

        $('#btnAddSection').css("display", "block");

    });

    $(document).ready(function () {
        //called when key is pressed in textbox
        $("#txtWeightage").keypress(function (e) {
            //if the letter is not digit then display error and don't type anything
            if (e.which != 8 && e.which != 0 && (e.which < 48 || e.which > 57)) {
                //display error message
                $("#errmsg").html("Digits Only").show().fadeOut("slow");
                return false;
            }
        });

        $("#Sectiontbl").hide();
    });

    $("#btnSectionSave").click(function () {
        // //
        
        var SectionName = $("#txtSectionName").val();
        var Weightage = $("#txtWeightage").val();
        var scoreCardName = $("#ScoreCardNameTxt").val();

        if (SectionName == "" || Weightage == "") {
            if (SectionName == "") {
                $("#SpanSectionError").text("Section is required.");
            }
            else {
                $("#SpanSectionError").text("");
            }
            if (Weightage == "") {
                $("#SpanWeightageError").text("Weightage is required.");
            }
            else {
                $("#SpanWeightageError").text("");
            }
        }
        else {
            $("#SpanSectionError").text("");
            $("#SpanWeightageError").text("");

            $.ajax({
                type: "POST",
                url: "../Audit/SectionSave",
                data: { 'sectionName': SectionName, 'weightage': Weightage, 'scorecardName': scoreCardName },
                contentType: 'application/x-www-form-urlencoded',
                datatype: "html",
                success: function (response) {
                    $('#ScoreCardLink').css("display", "block");
                    $("#Sectiontbl").show();
                    //console.log(response);
                    console.log(response.Status);
                    console.log(response.ScoreMasterListViewModel);
                    if (response.Status == false) {
                        toastr.warning('Before Section not completed. Please Check and try again..', 'Warning Alert', { timeOut: 3000 });
                    }
                    else {
                       // alert("Section name added successfully.");
                        toastr.success('Section name added successfully', 'Success Alert', { timeOut: 3000 });
                    }
                    ////
                    $("#myModal").modal('hide');
                    table = $('#Sectiontbl').DataTable({
                        "data": response.ScoreMasterListViewModel,
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

                        columns: [{
                            className: 'details-control',
                            orderable: false,
                            data: null,
                            defaultContent: ''
                        },

                        {
                            data: 'SectionName', className: 'sorting_1'
                        },
                        {
                            data: 'SectionWght', className: 'sorting_2'
                        },

                        {

                            data: 'Actions', 'width': '50px', 'render': function (data, type, row, meta) {
                                var str = "";
                                //return str = '<button type="button" class="btn btn-primary" id="btnSectionSave" click="EditSection();" name="BtnEDitSectionSave">EDIT</button>    <a href="/Audit/DeleteSection/' + row.scSectionID + '" title="Click here to edit category details" id="btnedit" class="getidcls" data-id="' + row.scSectionID + '"> <i class="far fa-edit primary"></i></a>';
                                return str = '<a href="javascript:void(0);" title="Edit" class="editsname" data-id="' + row.scSectionID + '" data-sname="' + row.SectionName + '" data-swghte="' + row.SectionWght + '"  ><i class="fa fa-pencil-square-o" aria-hidden="true"></i></a> <a href="javascript:void(0);" data-id="' + row.scSectionID + '" class="delete" title="Delete" ><i class="fa fa-times-circle" style="color:red" aria-hidden="true"></i></a> <a href="javascript:void(0);" title="AddParameter" class="AddParm" data-id="' + row.ScorecardID + '" data-name="' + row.scSectionID + '" ><i  class="fa fa-plus"></i></a>';
                                //< a href = "#" title = "Delete" > <i title="AddPara" class="AddParm" data-id="' + row.ScorecardID + '" data-name="' + row.scSectionID + '" class="far fa-trash-alt text-danger"></i></a > ';
                            }

                        }
                        ]
                    });

                },
                error: function () {
                    //alert("Error occured!!")
                    toastr.warning('Before Section Weightage < 100  or Section Weightage > 100 . Please Check and try again..', 'Warning Alert', { timeOut: 3000 });
                }
            });

        }


    });



    $(document).on("click", ".AddParm", function () {
        var scid = $(this).attr("data-id");
        var name = $(this).attr("data-name");
        $("#hdnScoreCardId").val(scid);
        $("#hdnSectionId").val(name);
        //  $('#btnParamSave').css("display", "block");

        // GetParamsDropDown();
        $("#MyParamModel").modal('show');


    });

    $(document).on("click", ".editsname", function () {
        ////
        var secid = $(this).attr("data-id");
        var sname = $(this).attr("data-sname");
        var swght = $(this).attr("data-swghte");

        $("#hdnsectionId").val(secid);
        $("#txtEDitSectionName").val(sname);
        $("#txtEDitWeightage").val(swght);
        $("#myEDISectionModal").modal('show');

    });

    $(document).on("click", ".delete", function () {
        ////
        if (confirm("Are you sure you want to delete?")) {
            var secid = $(this).attr("data-id");
            DeleteSection(secid);
        }
        return false;


    });






    var Id = "";
    function format(table_id) {
        // return '<table class="table table-striped" id="SKUtbl' + table_id + '" >' +
        return '<div class="scroller"><table class="table table-striped table-bordered table-md datatable" cellspacing="0"  id="Sectiontbl' + table_id + '" >' +
            '<thead>' +
            '<tr>' +
            //'<th class="custom-width">#</th>' +
            //'<th>Id</th>' +
            '<th class="custom-width">Title</th>' +
            '<th class="custom-width">Question Weight</th>' +
            '<th class="custom-width">Mandatory</th>' +
            '<th class="custom-width">Comments Required</th>' +
            '<th class="custom-width">Action</th>' +
            '</tr>' +
            '</thead>' +
            '</table></div>';

    }

    $('#Sectiontbl tbody').on('click', 'td.details-control', function () {
        ////


        //row.child(format2(rowData)).show()

        var tr = $(this).closest('tr');
        var row = table.row(tr);
        var rowData = row.data();
        // var ID = rowData.id;
        var ParamName = tr.find(".sorting_1").text();
        //var inventoryName = tr.find(".sorting_2").text();
        var scoreCardNameVal = $("#ScoreCardNameTxt").val();
        if (row.child.isShown()) {
            //  This row is already open - close it
            row.child.hide();
            tr.removeClass('shown');
        } else {
            // Open this row
            // alert(iTableCounter);
            row.child(format(iTableCounter)).show();

            tr.addClass('shown');
            $('#Sectiontbl').on('click', 'tbody td.editable', function (e) {
                editor.inline(this);
            });
            $.ajax({
                //type: "POST",
                url: "../Audit/GetParamsGridData",
                //url: "/Audit/GetParamsGridData",
                type: "GET",
                datatype: "json",
                data: { scorecardname: scoreCardNameVal, sectionname: ParamName },
                success: function (response1) {

                    oInnerTable = $('#Sectiontbl' + iTableCounter).dataTable({
                        "data": response1,
                        deferRender: true,
                        info: false,
                        lengthChange: false,
                        ordering: false,
                        paging: false,
                       
                        // scrollX: true,
                        // scrollY: true,
                        // scrollX: '350px',
                        searching: false,
                        //"orderCellsTop": true,
                        //"autoWidth": true,
                        //"deferRender": true,
                        //  console.log(response1);
                        "fnRowCallback": function (row, data, iDisplayIndex, iDisplayIndexFull) {
                            if (data.uomPrice >= "4000") {
                                $('td', row).css('background-color', 'LightGreen');
                            }
                            //else {
                            //    $('td', row).css('background-color', 'Orange');
                            //}
                        },

                        columns: [

                            {
                                data: 'ParamTitle', className: 'sorting_1 editable text'
                            },
                            {
                                data: 'SectionWght', className: 'sorting_2'
                            },
                            {
                                data: 'isMandatory', className: 'sorting_2'
                            },
                            {
                                data: 'IsCommentReq'
                            },

                            {

                                data: 'Actions', 'width': '50px', 'render': function (data, type, row, meta) {
                                    var str = "";
                                    //return str = '<button type="button" class="btn btn-primary" id="btnSectionSave" click="EditSection();" name="BtnEDitSectionSave">EDIT</button>    <a href="/Audit/DeleteSection/' + row.scSectionID + '" title="Click here to edit category details" id="btnedit" class="getidcls" data-id="' + row.scSectionID + '"> <i class="far fa-edit primary"></i></a>';
                                    return str = ' <a href="javascript:void(0);" data-id="' + row.scQuestionID + '" class="parmdelete" title="Delete" ><i class="fa fa-times-circle" style="color:red" aria-hidden="true"></i></a>&nbsp;&nbsp;<a href="javascript:void(0);" data-id="' + row.scQuestionID + '" class="parmedit" title="Edit" ><i class="fa fa-pencil-square-o" aria-hidden="true"></i></a>';

                                    //<a href="#" class="parmdelete" data-id="' + row.scQuestionID + '" title="Delete" ><i class="far fa-trash-alt text-danger"></i></a>< a href = "#" title = "Delete" > <i title="AddPara" class="AddParm" data-id="' + row.ScorecardID + '" data-name="' + row.scSectionID + '" class="far fa-trash-alt text-danger"></i></a > ';
                                }

                            }
                        ]

                    });
                    iTableCounter = iTableCounter + 1;
                }
            });
            // };
        }

    });

    $(document).on("click", ".parmdelete", function () {

        if (confirm("Are you sure you want to delete?")) {
            var sid = $(this).attr("data-id");
            DeleteParams(sid);
        }
        return false;


    });
    function fnResetControls() {
        var openedTextBox = $('#Sectiontbl').find('input');
        $.each(openedTextBox, function (k, $cell) {
            $(openedTextBox[k]).closest('td').html($cell.value);
        })
    }    
    
    $(document).on("click", ".paramcancel", function (e) {

        
            //var sid = $(this).attr("data-id");
            //DeleteParams(sid);
            var clickedRow = $($(this).closest('td')).closest('tr');
            fnResetControls();
            $(clickedRow).find('td .paramcancel').removeClass('paramcancel').addClass('parmdelete').attr('title', 'Delete').html('<i class="fa fa-times-circle" style="color:red" aria-hidden="true">');
            $(clickedRow).find('td .paramsave').removeClass('paramsave').addClass('parmedit').attr('title', 'Edit').html('<i class="fa fa-pencil-square-o" aria-hidden="true">');
            //$('#Sectiontbl tbody tr td .paramcancel').removeClass('paramcancel').addClass('parmdelete').html('Delete');
            //$('#Sectiontbl tbody tr td .paramsave').removeClass('paramsave').addClass('parmedit').html('Edit');  


    });
    $(document).on("click", ".paramsave", function (e) {
       
        
            var sid = $(this).attr("data-id");
            var openedTextBox = $('#Sectiontbl').find('input');
            UpdateParams(sid, openedTextBox.val());
           // var clickedRow = $($(this).closest('td')).closest('tr');
           
           // $(clickedRow).find('td .paramcancel').removeClass('paramcancel').addClass('parmdelete').attr('title', 'Delete').html('<i class="fa fa-times-circle" style="color:red" aria-hidden="true">');
            //$(clickedRow).find('td .paramsave').removeClass('paramsave').addClass('parmedit').attr('title', 'Edit').html('<i class="fa fa-pencil-square-o" aria-hidden="true">');
            //$('#Sectiontbl tbody tr td .paramcancel').removeClass('paramcancel').addClass('parmdelete').html('Delete');
            //$('#Sectiontbl tbody tr td .paramsave').removeClass('paramsave').addClass('parmedit').html('Edit');  
        


    });

    $(document).on("click", ".parmedit", function () {
        

        
            fnResetControls();

            var clickedRow = $($(this).closest('td')).closest('tr');
            $(clickedRow).find('td').each(function () {
                // do your cool stuff    
                if ($(this).hasClass('editable')) {
                    if ($(this).hasClass('text')) {
                        var html = fnCreateTextBox($(this).html(), 'ParamTitle');
                        $(this).html($(html))
                    }
                }
            });
            //$('#Sectiontbl tbody tr td .parmdelete').removeClass('parmdelete').addClass('paramcancel');
            //$('#Sectiontbl tbody tr td .parmedit').removeClass('parmedit').addClass('paramsave');
            $(clickedRow).find('td .parmdelete').removeClass('parmdelete').addClass('paramcancel').attr('title', 'Cancel').html('<i class="fa fa-ban" style="color:red" aria-hidden="true"></i>');
            $(clickedRow).find('td .parmedit').removeClass('parmedit').addClass('paramsave').attr('title', 'save').html('<i class="fa fa-floppy-o" style="color:blue" aria-hidden="true"></i>');
       


    });
    function fnCreateTextBox(value, fieldprop) {
        return '<input data-field="' + fieldprop + '" type="text" value="' + value + '" ></input>';
    }   
    function GetQSectionDetails() {
        var scoreCardName = $("#ScoreCardNameTxt").val();
        $.ajax({
            type: "POST",
            url: "/Audit/GetSectionDetails",
            //contentType: 'application/json; charset=utf-8',
            data: { 'scoreCardName': scoreCardName },
            contentType: 'application/x-www-form-urlencoded',
            datatype: "html",
            //data :""
            // dataType: "json" ,

            success: function (response) {

                // //
                // $("#myModal").modal('hide');

                table = $('#Sectiontbl').DataTable({

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

                    columns: [{
                        className: 'details-control custom-width',
                        orderable: false,
                        data: null,
                        defaultContent: ''
                    },

                    {
                        data: 'SectionName', className: 'sorting_1'
                    },
                    {
                        data: 'SectionWght',
                    },


                    {

                        data: 'Actions', 'width': '50px', 'render': function (data, type, row, meta) {
                            var str = "";
                            //return str = '<button type="button" class="btn btn-primary" id="btnSectionSave" click="EditSection();" name="BtnEDitSectionSave">EDIT</button>    <a href="/Audit/DeleteSection/' + row.scSectionID + '" title="Click here to edit category details" id="btnedit" class="getidcls" data-id="' + row.scSectionID + '"> <i class="far fa-edit primary"></i></a>';
                            // return str = '<a href="#" title="Edit" class="editsname" data-id="' + row.ScorecardID + '" ><i class="far fa-edit primary"></i></a> <a href="#" title="Delete" ><i class="far fa-trash-alt text-danger"></i></a> ';
                            return str = '<a href="javascript:void(0);" title="Edit" class="editsname" data-id="' + row.scSectionID + '" data-sname="' + row.SectionName + '" data-swghte="' + row.SectionWght + '"  ><i class="fa fa-pencil-square-o" aria-hidden="true"></i></a> <a href="javascript:void(0);" class="delete" data-id="' + row.scSectionID + '" title="Delete" ><i class="fa fa-times-circle" style="color:red" aria-hidden="true"></i></a> <a href="javascript:void(0);" title="AddParameter" class="AddParm" data-id="' + row.ScorecardID + '" data-name="' + row.scSectionID + '" ><i  class="fa fa-plus"></i></a>';
                        }

                    }
                    ]
                });

            },
            error: function () {
                //alert("Error occured!!")
            }
        });
    }




    function GetParamsDropDown() {
        ////

        debugger;

        $.ajax({
            type: "GET",
            url: "../Audit/GetParamsDetails",
            // data: '{name: "abc" }',
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (data) {
                ////

                var optionhtml1 = '<option value="' + 0 + '">' + "Select Parameter" + '</option>';
                //var optionhtml1 = '';
                $("#ddlParams").append(optionhtml1);

                $.each(data, function (index, element) {

                    var optionhtml = '<option value="' +
                        element.ParamId + '">' + element.ParamName + '</option>';
                    $("#ddlParams").append(optionhtml);
                });

            },
            failure: function () {
               alert("Failed getting params!");
            }
        });

    }

    $("#btnParamSave").click(function () {
        //$('#btnParamSave').css("display", "block");
        
        
        var count = 0;
        var minval = 0;
        var listcount = 0;
        var text = ""; var vl = "";
        var str = "";
        
       

        

        var ParamTitle = $("#txtParamName").val();  
        var Weightage = $("#txtParamWeightage").val(); 
        var radioValue = $("input[name='IsMandatory']:checked").val(); 
        var radioValue1 = $("input[name='IsCurrentReq']:checked").val(); 
        var SectionId = $("#hdnSectionId").val(); 
        var ScoreCardId = $("#hdnScoreCardId").val(); 
        var ParamId = $('#ddlParams option:selected').val(); 
        var listscale = $("#txtParamTitleListsacal").val(); 

        if (ParamId=="31") {

            var inputval = parseInt(listscale);
            var loopval = inputval;//3
            //var divend = 100;
            var subvalu = 100 / loopval;
            var lopval = 1 * subvalu.toFixed(2);
            var st = "1" + "|" + "0" + ",";
            var j = 2;
            for (var i = loopval; i > 1; i--) {

                st = st + j + "|" + lopval.toFixed(2) + ",";
                lopval = j * subvalu;
                j++;
                
            }
            st = st + j  + "|" + "100" + ",";
            str = st;
        }
        else if (ParamId == "29") {

            $(".someclass").each(function () {
                //debugger;


                var text = $(this).val();
                if (text != "" && text != null) {
                    listcount++;
                    str = str + text + "|";
                    count++;
                    if (count == 2) {
                        if (text == "100") {
                            minval++;
                        }
                        str = str + ",";
                        count = 0;
                    }
                }
            });
        }
        

        var paramlist = str;//$("#txtParamTitleList").val();
        paramlist = str.replace(/,\s*$/, "");


        if (ParamTitle == "" || Weightage == "" || ParamId == 0 || minval !=0  || listcount != 0) {
            //
            if (minval < 1 || listcount < 4) {
                if (minval < 1) { $("#SpanlistIdError").text("Paramter should have 100 value"); }
                if (listcount < 4) { $("#SpanlistIdError").text("Paramter should have two list value"); }
               
            }
            else {
                $("#SpanlistIdError").text("");
                $.ajax({
                    type: "POST",
                    url: "/Audit/AddParams",
                    //contentType: 'application/json; charset=utf-8',
                    data: { 'paramname': ParamTitle, 'paramweght': Weightage, 'isMandatory': radioValue, 'isCurrentReq': radioValue1, 'sectionid': SectionId, 'ScoreCardId': ScoreCardId, 'paramid': ParamId, 'paramlist': paramlist },
                    contentType: 'application/x-www-form-urlencoded',
                    datatype: "html",
                    //data :""
                    // dataType: "json" ,

                    success: function (data) {
                        $("#MyParamModel").modal('hide');
                        GetQSectionDetails();

                    },
                    error: function () {
                        toastr.warning('Question Weightage > 100 . Please Check and try again..', 'Warning Alert', { timeOut: 3000 });

                    }
                });

            }
            
            //
            if (ParamTitle == "") {
                $("#SpanTitleError").text("Title is required.");
            }
            else {
                $("#SpanTitleError").text(""); 
            }
            if (ParamId == 0) {
                $("#spanInventoryCodeId").text("Type is required.");
            }
            else {
                $("#spanInventoryCodeId").text(""); 
            }
            if (Weightage == "") {
                $("#SpanWeightageIdError").text("Weightage is required.");
            }
            else {
                $("#SpanWeightageIdError").text("");
            }
        }
        else {
            $("#SpanTitleError").text("");
            $("#SpanWeightageIdError").text("");
            $("#spanInventoryCodeId").text("");
            $("#SpanlistIdError").text("");

            //var paramId2 = ParamIdn != 'undefiened' ? ParamId : Param;
            $.ajax({
                type: "POST",
                url: "/Audit/AddParams",
                //contentType: 'application/json; charset=utf-8',
                data: { 'paramname': ParamTitle, 'paramweght': Weightage, 'isMandatory': radioValue, 'isCurrentReq': radioValue1, 'sectionid': SectionId, 'ScoreCardId': ScoreCardId, 'paramid': ParamId, 'paramlist': paramlist },
                contentType: 'application/x-www-form-urlencoded',
                datatype: "html",
                //data :""
                // dataType: "json" ,

                success: function (data) {
                    $("#MyParamModel").modal('hide');
                    GetQSectionDetails();

                },
                error: function () {
                    toastr.warning('Question Weightage > 100 . Please Check and try again..', 'Warning Alert', { timeOut: 3000 });
                    //alert("Error occured!!")
                }
            });
        }
    });



    $("#btnEditSectionSave").click(function () {
        var SectionName = $("#txtEDitSectionName").val();
        var Weightage = $("#txtEDitWeightage").val();
        var sectionId = $("#hdnsectionId").val();
        $.ajax({
            type: "POST",
            url: "/Audit/EditSection",
            //contentType: 'application/json; charset=utf-8',
            data: { 'sectionName': SectionName, 'sectionWeight': Weightage, 'sectionId': sectionId },
            contentType: 'application/x-www-form-urlencoded',
            datatype: "html",
            //data :""
            // dataType: "json" ,

            success: function (response) {
                $("#myEDISectionModal").modal('hide');
                GetQSectionDetails();
            },
            error: function () {
                toastr.warning('Total Sections Weightage > 100 . Please Check and try again..', 'Warning Alert', { timeOut: 3000 });
                //alert("Error occured!!")
            }

        });

    });

    function DeleteSection(SectionId) {
        ////
        $.ajax({
            type: "POST",
            url: "/Audit/DeleteSection",
            //contentType: 'application/json; charset=utf-8',
            data: { 'scSectionID': SectionId },
            contentType: 'application/x-www-form-urlencoded',
            datatype: "html",
            //data :""
            // dataType: "json" ,

            success: function (response) {
                GetQSectionDetails();
            },
            error: function () {
                //alert("Error occured!!")
            }

        });

    }




    function EditSection(id, sectionName, sectionweight) {
        ////
        $("#hdnsectionId").val(id);
        $("#txtEDitSectionName").val(sectionName);
        $("#txtEDitWeightage").val(sectionweight);
        $("#myEDISectionModal").modal('show');
    }

    //

    function DeleteParams(questionId) {
        ////
        $.ajax({
            type: "POST",
            url: "/Audit/DeleteParams",
            //contentType: 'application/json; charset=utf-8',
            data: { 'questionId': questionId },
            contentType: 'application/x-www-form-urlencoded',
            datatype: "html",
            //data :""
            // dataType: "json" ,

            success: function (response) {
                GetQSectionDetails();
            },
            error: function () {
                //alert("Error occured!!")
            }

        });
    }

    function UpdateParams(questionId, title) {
        
        ////
        $.ajax({
            type: "POST",
            url: "/Audit/UpdateQuestionParams",
            //contentType: 'application/json; charset=utf-8',
            data: { 'questionId': questionId, 'title': title},
            contentType: 'application/x-www-form-urlencoded',
            datatype: "html",
            //data :""
            // dataType: "json" ,

            success: function (response) {
                GetQSectionDetails();
            },
            error: function () {
                toastr.warning('Question Weightage > 100 . Please Check and try again..', 'Warning Alert', { timeOut: 3000 });
                //alert("Error occured!!")
            }

        });
    }




    $('#ScoreCardLink').click(function () {
        ////
        var firstname = $('#ScoreCardNameTxt').val();
        window.location.href = '@Url.Action("ScoreCardDetails", "Audit")?ScoreCardNameTxt=' + firstname;


        var url = window.location.href;
        var arr = url.split("/");
        var result = arr[0] + "//" + arr[2];


        window.location.href = result + '@Url.Action("ScoreCardDetails", "Audit")?ScoreCardNameTxt=' + firstname;

        return false;

    });
    //
    $(function () {
        $('#add').on('click', function (e) {
            e.preventDefault();
            $('<div/>').addClass('new-text-div')
                .html($('<input type="textbox" placeholder="text" name="nam" />&nbsp;<input type="textbox" placeholder="value" />&nbsp;').addClass('someclass'))
                .append($('<button/>').addClass('remove').text('Remove'))
                .insertBefore(this);
        });
        $(document).on('click', 'button.remove', function (e) {
            e.preventDefault();
            $(this).closest('div.new-text-div').remove();
        });
    });

    //List Values Input
    $("#ddlParams").change(function () {
        //debugger
        
        var ParamId = $('option:selected', this).val();
        //GetParamType
        //alert(ParamId);
        
        $.ajax({
            type: "GET",
            url: "/Audit/GetParamType",
            //contentType: 'application/json; charset=utf-8',
            data: { 'paramId': ParamId },
            contentType: 'application/x-www-form-urlencoded',
            datatype: "html",
            //data :""
            // dataType: "json" ,
            // console.log(response);
            success: function (response) {

                //debugger;
                $("#fm")[0].reset();
                $("div .new-text-div").empty();
                $("#SpanTitleError").text("");
                $("#SpanWeightageIdError").text("");
                $("#spanInventoryCodeId").text("");
                $("#SpanlistIdError").text("");
                $("#ddlParams").val(ParamId);
                if (response == "List") {
                    $('#divParamTitleListId').css("display", "block");
                }
                else {
                    $('#divParamTitleListId').css("display", "none");
                }
                if (response == "SList") {
                    $('#divParamTitleListScalingId').css("display", "block");
                }
                else {
                    $('#divParamTitleListScalingId').css("display", "none");
                }

            },
            error: function () {
                //alert("Error occured!!")
            }

        });

    });
});


$("#btnScSaveDA").click(function () {
   
    var ScoreCardNM = $("#ScoreCardNameTxt").val();
    var status = "2";
    var url = "/Audit/UpdateScoreCard";
    $.post(url, { ScoreCardNM: ScoreCardNM, status: status }, function (data) {
        $("#msg").html(data);
    })
        .done(function () {
            toastr.success('Scorecard DeActivated.', 'Success Alert', { timeOut: 2000 });
            window.location.href = '/Audit/GetScorecards'
        })
        .fail(function () {
            toastr.warning('Scorecard DeActivation failed, some Audits still in progress, please check...', 'Failure Alert', { timeOut: 2000 });
        });  
    ///debugger;
   
    
    //$.post('/Audit/GetScorecards', function (result) {});
    
});

$("#btnScSaveDraft").click(function () {
  
    var ScoreCardNM = $("#ScoreCardNameTxt").val();
    var status = "0";
    var url = "/Audit/UpdateScoreCard";
    $.post(url, { ScoreCardNM: ScoreCardNM, status: status }, function (data) {
        $("#msg").html(data);
    });  
   // debugger;
    toastr.success('Scorecard Saved as Draft.', 'Success Alert', { timeOut: 2000 });
    window.location.href = '/Audit/GetScorecards'
    //$.post('/Audit/GetScorecards', function (result) { });
 });

$("#btnScSave").click(function () {
  
    var scardnm = $("#ScoreCardNameTxt").val();;


    $.ajax({
        url: '/Audit/EditScoreCard',
        type: "Post",
        data: { 'ScoreCardNM': scardnm },
        success: function (response) {
            //alert("Audit deatils draft successfully");
            toastr.success('Scorecard Available for Audit.', 'Success Alert', { timeOut: 2000 });
            setTimeout(function () { window.location.reload(); }, 3000);
            $("#btnScSave").prop("disabled", true);
            $("#btnAddSection").prop("disabled", true);
            $("#btnScSaveDraft").prop("disabled", true);
      
        },
        error: function () { 
            toastr.warning('Scorecard Activation Failed. Please check wieghtage and try again ...', 'Failure Alert', { timeOut: 2000 });
        }
    });
    window.location.href = '/Audit/GetScorecards'
});


