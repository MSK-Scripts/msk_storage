var popupActive
var curPage
var currentStorage
var currentStorageId
var availableStorages
var locales = []

String.prototype.format = function () {
  var args = arguments;
  return this.replace(/{([0-9]+)}/g, function (match, index) {
    return typeof args[index] == 'undefined' ? match : args[index];
  });
};

window.addEventListener('message', function(event) {
  const data = event.data

  if (data.action == "openUI") {
    locales = data.locales
    currentStorage = data.currentStorage
    currentStorageId = data.storageId
    availableStorages = data.availableStorages

    $("#main-title-1").text(currentStorage.title)
    $("#main-title-2").text(currentStorage.subtitle)

    $("#info-title").text(locales.ui_info_title)
    $("#info-text").text(locales.ui_info_text.format(data.payCron))

    if (!data.hasStorage) {
      showPage("buy")
      $("#page-title-1").text(locales.ui_select_action_1)
      $("#page-title-2").text(locales.ui_select_action_2)
    } else {
      showPage("main")
    }

    $("#ui").fadeIn("fast")
  } else if (data.action == "closeUI") {
    closeUI()
  } 
})

$(document).ready(function() {
  $(".close-button").click(function() {
    if (this.id=="popup") {
      togglePopup()
    } else {
      closeUI()
    }
  })

  $(".back-button").click(function() {
    $("#page-title-1").text(locales.ui_select_action_1)
    $("#page-title-2").text(locales.ui_select_action_2)
    showPage("main")
  })
})

function action(type, method, storageId, storageData) {
  if (storageData) {
    storageData = JSON.parse(decodeURIComponent(storageData))
  }

  $.post(`https://${GetParentResourceName()}/action`, JSON.stringify({type: type, method: method, storageId: storageId, storageData: storageData}))
}

function togglePopup(show, type, storageId, storageData) {
  popupActive = show

  if (storageData) {
    storageData = JSON.parse(decodeURIComponent(storageData))
  }

  if (show) {
    $("#content").addClass("blur")
    $("#popup-buttons").empty()

    /* Übersetzen */
    if (type == "buy") {
      $("#popup-title").html(`<span class="white-mask">${locales.ui_buy_storage_1}</span><br><span class="green-mask">${locales.ui_buy_storage_2}</span>`)
      $('#popup-text').text(locales.ui_buy_storage_text.format(storageData.label[0], storageData.label[1], formatter.format(storageData.price)))

      $("#popup-buttons").append(`
        <button class="popup-button" onclick="action('buy', 'money', '${storageId}', '${encodeURIComponent(JSON.stringify(storageData))}')"><span class="white-mask"><i class="fa-solid fa-wallet"></i> ${locales.ui_money}</span></button>
        <button class="popup-button" onclick="action('buy', 'bank', '${storageId}', '${encodeURIComponent(JSON.stringify(storageData))}')"><span class="white-mask"><i class="fa-solid fa-credit-card"></i> ${locales.ui_bank}</span></button>
      `)
    } else if (type == "upgrade") {
      $("#popup-title").html(`<span class="white-mask">${locales.ui_buy_storage_1}</span><br><span class="green-mask">${locales.ui_buy_storage_2}</span>`)
      $('#popup-text').text(locales.ui_upgrade_storage_text.format(storageData.label[0], storageData.label[1], formatter.format(storageData.price)))

      $("#popup-buttons").append(`
        <button class="popup-button" onclick="action('upgrade', 'money', '${storageId}', '${encodeURIComponent(JSON.stringify(storageData))}')"><span class="white-mask"><i class="fa-solid fa-wallet"></i> ${locales.ui_money}</span></button>
        <button class="popup-button" onclick="action('upgrade', 'bank', '${storageId}', '${encodeURIComponent(JSON.stringify(storageData))}')"><span class="white-mask"><i class="fa-solid fa-credit-card"></i> ${locales.ui_bank}</span></button>
      `)
    } else {
      $("#popup-title").html(`<span class="white-mask">${locales.ui_cancel_storage_1}</span><br><span class="red-mask">${locales.ui_cancel_storage_2}</span>`)
      $('#popup-text').text(locales.ui_sell_storage)

      $("#popup-buttons").append(`
        <button class="popup-button" onclick="action('sell')"><span class="white-mask"><span><i class="fa-solid fa-ban"></i> ${locales.ui_cancel_storage_1} ${locales.ui_cancel_storage_2}</span></span></button>
      `)
    }
    $(".popup").fadeIn("fast")
  } else {
    $("#content").removeClass("blur")
    $(".popup").fadeOut("fast")
  }
}

function showPage(page) {
  curPage = page

  $(".container-page").hide()
  $(".back-button").show()

  let disabled = 'none'
  let upgrade_label = `<span class="white-mask">${locales.ui_open_upgrade_1}</span> <span class="green-mask">${locales.ui_open_upgrade_2}</span>`

  if (availableStorages.length == 0) {
    disabled = 'disabled'
    upgrade_label = `<span class="white-mask">${locales.ui_max_upgrade_1}</span> <span class="green-mask">${locales.ui_max_upgrade_2}</span>`
  }

  if (page == "main") {
    $(".back-button").hide()
    $("#category-list").empty()

    $("#category-list").append(`
      <div class="main-page-category-item" id="open-storage">
        <span class="white-mask">${locales.ui_open_storage_1}</span> <span class="green-mask">${locales.ui_open_storage_2}</span>
        <div class="main-page-category-item-image"><i class="fa-solid fa-warehouse-full"></i></div>
      </div>
      <div class="main-page-category-item ${disabled}" id="manage-storage">
        ${upgrade_label}
        <div class="main-page-category-item-image"><i class="fa-solid fa-hammer"></i></div>
      </div>
      <div class="main-page-category-item" id="cancel-storage">
        <span class="white-mask">${locales.ui_cancel_storage_1}</span> <span class="red-mask">${locales.ui_cancel_storage_2}</span>
        <div class="main-page-category-item-image"><i class="fa-solid fa-ban"></i></div>
      </div>
    `)

    $(".main-page-category-item").click(function() {
      if (this.id == "open-storage") {
        $.post(`https://${GetParentResourceName()}/openStorage`)
      } else if (this.id == "manage-storage") {
        $("#page-title-1").text(locales.ui_open_upgrade_1)
        $("#page-title-2").text(locales.ui_open_upgrade_2)
        showPage("upgrade")
      } else if (this.id == "cancel-storage") {
        togglePopup(true, "sell")
      }
    })

    $("#main-page").show()
  } else if (page == "buy") {
    $(".back-button").hide()
    $("#upgrade-list").empty()
  
    availableStorages.forEach(function(v, k) {
      const id = k + 1

      if (v) {
        const price = formatter.format(v.price)
        const weight = numberWithDots(v.weight)

        $("#upgrade-list").append(`
          <div class="upgrade-list-item">
            <button class="upgrade-list-item-title-box"><span class="white-mask">${v.label[0]}</span> <span class="green-mask">${v.label[1]}</span></button>
            <div class="upgrade-list-item-image" style="background-image:url(images/${v.image})">
                <div class="upgrade-list-info-box">
                  <div class="upgrade-list-info-box-item"><span class="white-mask">Kapazität:</span> <span class="green-mask">${weight} KG</span></div>
                  <div class="upgrade-list-info-box-item"><span class="white-mask">Preis:</span> <span class="green-mask">$${price}</span></div>
                </div>
            </div>
            <button class="upgrade-list-item-button" onclick="togglePopup('${true}', 'buy', '${id}', '${encodeURIComponent(JSON.stringify(v))}')"><span class="white-mask">${locales.ui_buy}</span></button>
          </div>
        `)
      }
    })
    $("#upgrade-page").show()
  } else if (page == "upgrade") {
    $("#upgrade-list").empty()
    
    availableStorages.forEach(function(v, k) {
      const id = k + 1

      if (v) {
        const price = formatter.format(v.price)
        const weight = numberWithDots(v.weight)

        $("#upgrade-list").append(`
          <div class="upgrade-list-item">
            <button class="upgrade-list-item-title-box"><span class="white-mask">${v.label[0]}</span> <span class="green-mask">${v.label[1]}</span></button>
            <div class="upgrade-list-item-image" style="background-image:url(images/${v.image})">
                <div class="upgrade-list-info-box">
                  <div class="upgrade-list-info-box-item"><span class="white-mask">Kapazität:</span> <span class="green-mask">${weight} KG</span></div>
                  <div class="upgrade-list-info-box-item"><span class="white-mask">Preis:</span> <span class="green-mask">$${price}</span></div>
                </div>
            </div>
            <button class="upgrade-list-item-button" onclick="togglePopup('${true}', 'upgrade', '${id}', '${encodeURIComponent(JSON.stringify(v))}')"><span class="white-mask">${locales.ui_upgrade}</span></button>
          </div>
        `)
      }
    })
    $("#upgrade-page").show()
  }
}

document.onkeyup = function (event) {
  if (event.key == "Escape") {
    if (popupActive) {
      togglePopup()
    } else {
      if (curPage == "main" || curPage == "buy") {
        closeUI()
      } else {
        $("#page-title-1").text(locales.ui_select_action_1)
        $("#page-title-2").text(locales.ui_select_action_2)
        showPage("main")
      }
    }
  }
}

function closeUI() {
  togglePopup()
  $("#ui").fadeOut("fast")
  $.post(`https://${GetParentResourceName()}/closeUI`)
}

function numberWithDots(number) {
  return number.toString().replace(/\B(?<!\.\d*)(?=(\d{3})+(?!\d))/g, ".");
}

const formatter = new Intl.NumberFormat('en-US', {
  minimumFractionDigits: 0,
});