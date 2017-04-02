class Importer

  attr_accessor :filename, :schema, :limit, :offset

  def osdi_for_row(r)
    s=@schema

    psh={}
    cf={}
    data= {
        given_name: r[s[:given_name]],
        family_name: r[s[:family_name]],


    }

    if email=r[s[:email_address]]
      data[:email_addresses]=[
          {
              address: email
          }
      ]
    end
    phone_numbers=[]
    if home_phone=r[s[:home_phone]]
      if hpf=s.dig(:phone_custom_fields, :home_phone).presence
        cf[hpf]=Mixer._phone_simplify(home_phone)
      else
        phone_numbers << {
            number: Mixer._phone_simplify(home_phone),
            number_type: 'Home'

        }
      end
    end

    if mobile_phone=r[s[:mobile_phone]].presence
      if mpf=s.dig(:phone_custom_fields, :mobile_phone).presence
        cf[mpf]=Mixer._phone_simplify(mobile_phone)
      else
      phone_numbers << {
          number: Mixer._phone_simplify(mobile_phone),
          number_type: 'Mobile'
      }

      end
    end
    data[:phone_numbers]=phone_numbers if phone_numbers.present?

    if cfs=s[:custom_fields]

      cfs.each do |k, col|
        cf[k]=r[col]
      end

    end

    psh[:person]=data
    psh[:person][:custom_fields]=cf if cf.present?

    if tags=s[:tags]
      add_tags=[]
      tags.each do |k, col|
        if r[col].present?
          add_tags << k.downcase
        end
      end
      psh[:add_tags]=add_tags
    end

    options={
        mobile: mobile_phone,
        email: email,
        home: home_phone
    }

    psh
  end

  def run
    rows=CSV.read(@filename, headers: true)

    run_offset= self.offset ? self.offset : 0
    run_limit=run_offset + (self.limit ? (self.limit - 1) : (rows.count - 1))
    rows_to_process = rows[run_offset..run_limit]

    osdi_rows=rows_to_process.map { |r| self.osdi_for_row r }

  end

end