// sticky header
$(window).scroll(function(){
    // if ($(window).scrollTop() >= 50) {
    //     $('header').addClass('sticky');
    // }
    // else {
        
    //     $('header').removeClass('sticky');
    // }
});
// $(window).scroll(function () {
//     if ($(window).scrollTop() > 79) {
//         $('.header').css({
//             'position': 'fixed',
//             'width': '100%',
//             'z-index': '9'
//         });
//     } else {
//         $('.header').css({
//             position: 'static',
//             top: '0px'
//         });
//     }
// });

// Example starter JavaScript for disabling form submissions if there are invalid fields
(function () {
    'use strict';
    window.addEventListener('load', function () {
        var forms = document.getElementsByClassName('needs-validation');
        var validation = Array.prototype.filter.call(forms, function (form) {
            form.addEventListener('submit', function (event) {
                if (form.checkValidity() === false) {
                    event.preventDefault();
                    event.stopPropagation();
                }
                form.classList.add('was-validated');
            }, false);
        });
    }, false);
})();

// tooltip 
$(document).ready(function () {
    $('[data-toggle="tooltip"]').tooltip();
    $('#activedate,#adminroster-deactivationdatepicker,#adminroster-lastpaydatepicker,#adminreport-from,#adminreport-to').datepicker({
        format: "dd/mm/yyyy",
        // uiLibrary: 'bootstrap4',
        autoclose: true,
        todayHighlight: true
    });
    $("#drivingstates").tagsinput('items');
});

// Drag and Drop Upload js
// function readUrl(input) {

//     if (input.files && input.files[0]) {
//       let reader = new FileReader();
//       reader.onload = (e) => {
//         let imgData = e.target.result;
//         let imgName = input.files[0].name;
//         input.setAttribute("data-title", imgName);
//         console.log(e.target.result);
//       }
//       reader.readAsDataURL(input.files[0]);
//     }

//   }

/*================================ Datatable Js ==================================*/

// Admin roster data table js start
$(document).ready(function () {
    var table = $('#example').DataTable({
        "scrollX": true,
    });
    $('#example tbody').on('click', 'tr', function () {
        if ($(this).hasClass('selected')) {
            $(this).removeClass('selected');
        } else {
            table.$('tr.selected').removeClass('selected');
            $(this).addClass('selected');
        }
    });
    $('#button').click(function () {
        table.row('.selected').remove().draw(false);
        $('#alldrivers-update-btn').css({
            'display': 'none'
        });
    });
});
$('#example').on("click", ".selected", function () {
    $('#alldrivers-update-btn').css({
        'display': 'block'
    });
    $(this).closest('tr').find('td:nth-child(2)').each(function () {
        var html = $(this).html();
        var input = $('<input type="text" />');
        input.val(html);
        $(this).html(input);
    });
    $(this).closest('tr').find('td:nth-child(4)').each(function () {
        var html = $(this).html();
        var input = $('<select><option value="">None</option><option value="">Manager</option><option value="">Driver</option> <option value="">Admin</option> </select>');
        input.val(html);
        $(this).html(input);
    });
    $(this).closest('tr').find('td:nth-child(5)').each(function () {
        var html = $(this).html();
        var input = $('<input type="text" />');
        input.val(html);
        $(this).html(input);
    });
    $(this).closest('tr').find('td:nth-child(6)').each(function () {
        var html = $(this).html();
        var input = $('<select><option value="">Tiger</option><option value="">Jane Done</option><option value="">xyz</option> <option value="">abc</option> </select>');
        input.val(html);
        $(this).html(input);
    });
    $(this).closest('tr').find('td:nth-child(7)').each(function () {
        var html = $(this).html();
        var input = $('<input type="text" />');
        input.val(html);
        $(this).html(input);
    });
});
// Admin roster tag remove js
closeBtn = $('.tagclose');
imageHolder = $('.adminroster-driverstatus');
closeOnClick();

function closeOnClick() {
    closeBtn.on('click', function () {
        $(this).parent().remove();
    });
}

// Admin dashboard js
$(document).ready(function () {
    var table = $('#admin-dashbord').DataTable({
        "scrollX": true,
    });
    $('#admin-dashbord tbody').on('click', 'tr', function () {
        if ($(this).hasClass('selected')) {
            $(this).removeClass('selected');
        } else {
            table.$('tr.selected').removeClass('selected');
            $(this).addClass('selected');
        }
    });
    $('#button').click(function () {
        table.row('.selected').remove().draw(false);
    });
});

// Admin report data table js
$(document).ready(function () {
    var table = $('#admin-report').DataTable({
        "scrollX": true,
    });
    $('#admin-report tbody').on('click', 'tr', function () {
        if ($(this).hasClass('selected')) {
            $(this).removeClass('selected');
        } else {
            table.$('tr.selected').removeClass('selected');
            $(this).addClass('selected');
        }
    });
    $('#button').click(function () {
        table.row('.selected').remove().draw(false);
    });
});

// Driver dashbord data table js
$(document).ready(function () {
    var table = $('#driver-dashbord').DataTable({
        "scrollX": true,
    });
    $('#driver-dashbord tbody').on('click', 'tr', function () {
        if ($(this).hasClass('selected')) {
            $(this).removeClass('selected');
        } else {
            table.$('tr.selected').removeClass('selected');
            $(this).addClass('selected');
        }
    });
    $('#button').click(function () {
        table.row('.selected').remove().draw(false);
    });
});

// Driver Dashbord model data table js
$(document).ready(function () {
    var table = $('#driver-dashbord-month-model').DataTable({
        "scrollX": true,
    });
    jQuery('.modal-body .dataTable').wrap('<div class="modal_dataTables_scroll" />');
    $('#driver-dashbord-month-model tbody').on('click', 'tr', function () {
        if ($(this).hasClass('selected')) {
            $(this).removeClass('selected');
        }
        else {
            table.$('tr.selected').removeClass('selected');
            $(this).addClass('selected');
        }
    });
    $('#button').click(function () {
        table.row('.selected').remove().draw(false);
    });
});

// manager dashboard team record tab js
$(document).ready(function () {
    var table = $('#manager-dashbord-team-record').DataTable({
        "scrollX": true,
    });
    $('#manager-dashbord-team-record tbody').on('click', 'tr', function () {
        if ($(this).hasClass('selected')) {
            $(this).removeClass('selected');
        }
        else {
            table.$('tr.selected').removeClass('selected');
            $(this).addClass('selected');
        }
    });
    $('#button').click(function () {
        table.row('.selected').remove().draw(false);
    });
});

// manager dashboard unapproved record tab js
$(document).ready(function () {
    var table = $('#manager-dashbord-unapproved-record').DataTable({
        "scrollX": true,
    });
    $('#manager-dashbord-unapproved-record tbody').on('click', 'tr', function () {
        if ($(this).hasClass('selected')) {
            $(this).removeClass('selected');
        } else {
            table.$('tr.selected').removeClass('selected');
            $(this).addClass('selected');
        }
    });
    $('#button').click(function () {
        table.row('.selected').remove().draw(false);
    });
});

// Driver Dashbord select model data table js
$(document).ready(function () {
    var table = $('#driver-dashbord-select-model').DataTable({
        "scrollX": true,
    });
    $('#driver-dashbord-select-model').on('click', 'tr', function () {
        if ($(this).hasClass('selected')) {
            $(this).removeClass('selected');
        } else {
            table.$('tr.selected').removeClass('selected');
            $(this).addClass('selected');
        }
    });
    $('#button').click(function () {
        table.row('.selected').remove().draw(false);
    });
});

// driver-dashboard-upload-insurancebtn button model data table js
$(document).ready(function () {
    // var table = $('#driver-dashboard-upload-insurancebtn').DataTable();
    // $('#driver-dashboard-upload-insurancebtn tbody').on( 'click', 'tr', function () {
    //     if ( $(this).hasClass('selected') ) {
    //         $(this).removeClass('selected');
    //     }
    //     else {
    //         table.$('tr.selected').removeClass('selected');
    //         $(this).addClass('selected');
    //     }
    // } );

});


// Driver Manager dashboard js
$(document).ready(function () {
    var table = $('#driver-manager-dashbord-myteam').DataTable({
        "scrollX": true,
    });
    $('#driver-manager-dashbord-myteam tbody').on('click', 'tr', function () {
        if ($(this).hasClass('selected')) {
            $(this).removeClass('selected');
        } else {
            table.$('tr.selected').removeClass('selected');
            $(this).addClass('selected');
        }
    });
    $('#button').click(function () {
        table.row('.selected').remove().draw(false);
    });
});

// Driver Manager dashboard js
$(document).ready(function () {
    var table = $('#driver-manager-dashbord-mileage').DataTable({
        "scrollX": true,
    });
    $('#driver-manager-dashbord-mileage tbody').on('click', 'tr', function () {
        if ($(this).hasClass('selected')) {
            $(this).removeClass('selected');
        } else {
            table.$('tr.selected').removeClass('selected');
            $(this).addClass('selected');
        }
    });
    $('#button').click(function () {
        table.row('.selected').remove().draw(false);
    });
});

// Driver manager dashbord data table js
$(document).ready(function () {
    var table = $('#driver-manager-dashbord').DataTable({
        "scrollX": true,
    });
    $('#driver-manager-dashbord tbody').on('click', 'tr', function () {
        if ($(this).hasClass('selected')) {
            $(this).removeClass('selected');
        } else {
            table.$('tr.selected').removeClass('selected');
            $(this).addClass('selected');
        }
    });
    $('#button').click(function () {
        table.row('.selected').remove().draw(false);
    });
});


// Driver Dashbord select model data table js
$(document).ready(function () {
    var table = $('#driver-manager-dashbord-select-model').DataTable({
        "scrollX": true,
    });
    $('#driver-manager-dashbord-select-model').on('click', 'tr', function () {
        if ($(this).hasClass('selected')) {
            $(this).removeClass('selected');
        } else {
            table.$('tr.selected').removeClass('selected');
            $(this).addClass('selected');
        }
    });
    $('#button').click(function () {
        table.row('.selected').remove().draw(false);
    });
});




// Driver Dashbord select model data table js
$(document).ready(function () {
    var table = $('#admin-dashboard-loginbtn').DataTable({
        "scrollX": true,
    });
    jQuery('.tab-pane .dataTable').wrap('<div class="tab_dataTables_scroll" />');

    $('#admin-dashboard-loginbtn').on('click', 'tr', function () {
        if ($(this).hasClass('selected')) {
            $(this).removeClass('selected');
        } else {
            table.$('tr.selected').removeClass('selected');
            $(this).addClass('selected');
        }
    });
    $('#button').click(function () {
        table.row('.selected').remove().draw(false);
    });
});


// Admin dashboard js
$(document).ready(function () {
    var table = $('#admin-dashbord-mileage').DataTable({
        "scrollX": true,
    });
    $('#admin-dashbord-mileage tbody').on('click', 'tr', function () {
        if ($(this).hasClass('selected')) {
            $(this).removeClass('selected');
        } else {
            table.$('tr.selected').removeClass('selected');
            $(this).addClass('selected');
        }
    });
    $('#button').click(function () {
        table.row('.selected').remove().draw(false);
    });
});
